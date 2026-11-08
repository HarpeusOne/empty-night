class_name BuildingKit
extends RefCounted

## Builds one house from a footprint ring and an archetype (data/buildings/archetypes.json) into a LowPoly mesh
## kit plus wall collision faces. Coordinates: ring in Godot (x, z), ground at y = 0.
##
## Walls: one quad per footprint edge, darker at the foot (baked grime). Openings are textured quads 3 cm in front
## of the wall (the walls stay solid: interiors are separate scenes). Roofs need a near-rectangular footprint
## (gable / hip); an irregular one falls back to a flat roof and is reported (the editor offers "rectangle").

const WALL_TILE := 3.0
const ROOF_TILE := 2.0
const GABLE_FILL_MIN := 0.86
const UP := Vector3.UP
const DIRT := Color(0.44, 0.42, 0.38)

var lp: LowPoly
var col: PackedVector3Array
var stats := {"gable": 0, "hip": 0, "flat": 0, "none": 0, "irregular": 0, "roof_fail": 0, "windows": 0}


func _init(p_lp: LowPoly, p_col: PackedVector3Array) -> void:
	lp = p_lp
	col = p_col


static func signed_area(ring: PackedVector2Array) -> float:
	var s := 0.0
	for i in range(ring.size()):
		var a := ring[i]
		var b := ring[(i + 1) % ring.size()]
		s += a.x * b.y - b.x * a.y
	return s * 0.5


static func centroid(ring: PackedVector2Array) -> Vector2:
	var c := Vector2.ZERO
	for v in ring:
		c += v
	return c / maxf(float(ring.size()), 1.0)


## Oriented bounding rectangle along the longest edge, long side first: {e1, e2, smin, smax, tmin, tmax}.
static func obr(ring: PackedVector2Array) -> Dictionary:
	var n := ring.size()
	var longest := 0
	var longest_len := 0.0
	for i in range(n):
		var l := ring[i].distance_to(ring[(i + 1) % n])
		if l > longest_len:
			longest_len = l
			longest = i
	var e1 := (ring[(longest + 1) % n] - ring[longest]).normalized()
	var e2 := Vector2(-e1.y, e1.x)
	var ext := _extent(ring, e1, e2)
	if (ext[3] - ext[2]) > (ext[1] - ext[0]):
		var swapped := e1
		e1 = e2
		e2 = -swapped
		ext = _extent(ring, e1, e2)
	return {"e1": e1, "e2": e2, "smin": ext[0], "smax": ext[1], "tmin": ext[2], "tmax": ext[3]}


static func _extent(ring: PackedVector2Array, e1: Vector2, e2: Vector2) -> Array:
	var smin := INF
	var smax := -INF
	var tmin := INF
	var tmax := -INF
	for v in ring:
		var s := v.dot(e1)
		var t := v.dot(e2)
		smin = minf(smin, s)
		smax = maxf(smax, s)
		tmin = minf(tmin, t)
		tmax = maxf(tmax, t)
	return [smin, smax, tmin, tmax]


## The oriented bounding rectangle as a ring (same winding as the input).
static func rect_ring(ring: PackedVector2Array) -> PackedVector2Array:
	var b := obr(ring)
	var e1: Vector2 = b["e1"]
	var e2: Vector2 = b["e2"]
	var out := PackedVector2Array([e1 * b["smin"] + e2 * b["tmin"], e1 * b["smax"] + e2 * b["tmin"],
		e1 * b["smax"] + e2 * b["tmax"], e1 * b["smin"] + e2 * b["tmax"]])
	if (signed_area(out) > 0.0) != (signed_area(ring) > 0.0):
		out.reverse()
	return out


static func fill_ratio(ring: PackedVector2Array) -> float:
	var b := obr(ring)
	var area := (float(b["smax"]) - float(b["smin"])) * (float(b["tmax"]) - float(b["tmin"]))
	return absf(signed_area(ring)) / maxf(area, 0.001)


## Wall height of an archetype (storeys x storey height + attic knee wall). `storeys` <= 0: use `data_height`.
static func wall_height(arch: Dictionary, storeys: int, data_height: float) -> float:
	if storeys <= 0:
		return maxf(data_height, 2.5)
	return storeys * float(arch["storey_h"]) + float(arch.get("knee", 0.0))


## o: {id, storeys, data_height, road (Vector2 nearest road point), ridge_flip, tint (int, -1 = by id),
##     facade (wall material, "" = the type's), openings (Array of openings set by hand, null = automatic)}.
## Returns {wall_h, top (highest point), roof (what was built), irregular, walls, openings (the ones in use)}.
func building(ring: PackedVector2Array, arch: Dictionary, o: Dictionary) -> Dictionary:
	var id := int(o.get("id", 0))
	var storeys := int(o.get("storeys", arch["storeys"]))
	var wall_h := wall_height(arch, storeys, float(o.get("data_height", 3.0)))
	var tints: Array = arch["tints"]
	var ti := int(o.get("tint", -1))
	var tc: Array = tints[(ti if ti >= 0 else absi(id)) % tints.size()]
	var tint := Color(tc[0], tc[1], tc[2])
	var wall_key := String(o.get("facade", arch["wall"]))
	if wall_key == "":
		wall_key = String(arch["wall"])
	var roof_type := String(arch["roof"])
	var open_top := roof_type == "none"
	var n := ring.size()
	var outward_right := signed_area(ring) > 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = absi(id) + 7

	# the wall closest to the nearest road gets the door
	var door := String(arch["door"])
	var min_door_edge := 3.2 if door == "garage" or door == "barn" else 2.6
	var road: Vector2 = o.get("road", centroid(ring))
	var door_edge := -1
	var door_best := INF
	for i in range(n):
		var ea := ring[i]
		var eb := ring[(i + 1) % n]
		if ea.distance_to(eb) < min_door_edge:
			continue
		var dd := ((ea + eb) * 0.5).distance_to(road)
		if dd < door_best:
			door_best = dd
			door_edge = i

	var c_bot := DIRT * tint
	var perim := 0.0
	var walls: Array = []          # per ring edge: {a, b, n (outward), len}; the editor picks walls with it
	var plan: Array = []
	var has_explicit: bool = o.get("openings") != null
	var explicit: Array = o.get("openings", []) if has_explicit else []
	for i in range(n):
		var a := ring[i]
		var b := ring[(i + 1) % n]
		var d := b - a
		var length := d.length()
		if length < 0.01:
			walls.append({"a": a, "b": b, "n": Vector2.ZERO, "len": 0.0})
			continue
		var n2 := (Vector2(d.y, -d.x) if outward_right else Vector2(-d.y, d.x)).normalized()
		var out_n := Vector3(n2.x, 0.0, n2.y)
		var a0 := Vector3(a.x, 0.0, a.y)
		var b0 := Vector3(b.x, 0.0, b.y)
		var a1 := Vector3(a.x, wall_h, a.y)
		var b1 := Vector3(b.x, wall_h, b.y)
		var u0 := perim / WALL_TILE
		var u1 := (perim + length) / WALL_TILE
		perim += length
		var v_bot := wall_h / WALL_TILE
		lp.quad_out(wall_key, a0, b0, b1, a1, Vector2(u0, v_bot), Vector2(u1, v_bot), Vector2(u1, 0), Vector2(u0, 0), c_bot, tint, out_n)
		if open_top:
			# no roof: the inside of the walls is visible from above
			lp.quad_out(wall_key, a0, b0, b1, a1, Vector2(u0, v_bot), Vector2(u1, v_bot), Vector2(u1, 0), Vector2(u0, 0),
				c_bot * 0.8, tint * 0.75, -out_n)
		col.append_array([a0, b0, b1, a0, b1, a1])
		walls.append({"a": a, "b": b, "n": n2, "len": length})
		var wall_list := explicit if has_explicit else _plan_openings(arch, storeys, i == door_edge, rng, i, length, wall_h)
		if not has_explicit:
			plan.append_array(wall_list)
		_draw_openings(wall_list, i, a0, b0, out_n, length, wall_h)

	var res := {"wall_h": wall_h, "top": wall_h, "roof": roof_type, "irregular": false, "walls": walls,
		"openings": explicit if has_explicit else plan}
	_roof(ring, arch, id, wall_h, tint, wall_key, bool(o.get("ridge_flip", false)), res)
	return res


## Windows and doors the author can place by hand (F2 -> Budynki -> O). y = bottom edge above the ground.
## `mat` = material key, `ground` = always stands on the ground (doors, gates).
const OPENING_KINDS := {
	"win": {"label": "Okno", "mat": "win", "w": 1.1, "h": 1.3, "y": 0.9},
	"win_lit": {"label": "Okno (świeci nocą)", "mat": "win_lit", "w": 1.1, "h": 1.3, "y": 0.9},
	"win_small": {"label": "Okienko", "mat": "win", "w": 0.7, "h": 0.6, "y": 1.7},
	"win_wide": {"label": "Okno szerokie", "mat": "win", "w": 2.0, "h": 1.1, "y": 1.1},
	"shop": {"label": "Witryna", "mat": "b_shopfront", "w": 2.4, "h": 2.0, "y": 0.5},
	"hole": {"label": "Otwór bez szyby", "mat": "c_black", "w": 1.2, "h": 1.4, "y": 0.85},
	"door": {"label": "Drzwi", "mat": "door", "w": 1.0, "h": 2.1, "y": 0.0, "ground": true},
	"door_dark": {"label": "Wejście ciemne", "mat": "c_black", "w": 1.0, "h": 2.2, "y": 0.0, "ground": true},
	"garage": {"label": "Brama garażowa", "mat": "b_garage", "w": 2.6, "h": 2.2, "y": 0.0, "ground": true},
	"barn": {"label": "Wrota", "mat": "g_darkwood", "w": 3.2, "h": 3.0, "y": 0.0, "ground": true},
}
const OPENING_ORDER := ["win", "win_lit", "win_small", "win_wide", "shop", "hole", "door", "door_dark", "garage", "barn"]
## Wall finishes (elewacja) the author can pick instead of the type's own: [material key, label].
const FACADES := [["wall", "Tynk jasny"], ["wall2", "Tynk szary"], ["brick", "Cegła"], ["planks", "Deski"],
	["b_breeze", "Pustaki"], ["c_plaster", "Tynk biały (jak kościół)"]]


static func facade_label(key: String) -> String:
	for f in FACADES:
		if f[0] == key:
			return String(f[1])
	return key


## The automatic windows and door of one wall, as openings {e, t (centre, 0..1 along the wall), y, w, h, k}.
func _plan_openings(arch: Dictionary, storeys: int, has_door: bool, rng: RandomNumberGenerator, e: int,
		length: float, wall_h: float) -> Array:
	var out: Array = []
	if length < 2.0:
		return out
	var style := String(arch["windows"])
	var door := String(arch["door"])
	var sh := float(arch["storey_h"])
	var floors := storeys if storeys > 0 else clampi(int(round(wall_h / 3.0)), 1, 4)
	var door_w := {"house": 1.0, "garage": 2.6, "barn": 3.2, "none": 1.0}.get(door, 1.0) as float
	var door_h := {"house": 2.1, "garage": 2.2, "barn": minf(3.4, wall_h - 0.3), "none": 2.2}.get(door, 2.1) as float
	var door_t := -1.0
	if has_door:
		var margin := (door_w * 0.5 + 0.4) / length
		door_t = rng.randf_range(maxf(0.25, margin), minf(0.75, 1.0 - margin)) if margin < 0.5 else 0.5
	var win_w := 1.1
	var win_h := 1.3
	var win_y := 1.55
	var spacing := 3.4
	var kind := "win"
	match style:
		"none":
			floors = 0
		"small":
			win_w = 0.7
			win_h = 0.6
			win_y = minf(2.0, wall_h - 0.6)
			spacing = 3.0
			floors = 1
			kind = "win_small"
		"holes":
			win_w = 1.2
			win_h = 1.4
			kind = "hole"
		"band":
			win_w = 2.0
			win_h = 1.1
			win_y = wall_h - 1.2
			floors = 1
			kind = "win_wide"
	var count := maxi(int(length / spacing), 1)
	for f in range(floors):
		for k in range(count):
			var t := (float(k) + 0.5) / count
			var w := win_w
			var h := win_h
			var y := win_y + f * sh
			var k_kind := kind
			if style == "shop" and f == 0 and has_door:
				w = 2.4
				h = 2.0
				y = 1.5
				k_kind = "shop"
			if has_door and f == 0 and absf(t - door_t) * length < door_w * 0.5 + w * 0.5 + 0.3:
				continue
			if t * length < w * 0.5 + 0.3 or (1.0 - t) * length < w * 0.5 + 0.3:
				continue
			if y + h * 0.5 > wall_h - 0.15:
				continue
			if k_kind == "win" and rng.randf() < 0.22:
				k_kind = "win_lit"
			out.append({"e": e, "t": snappedf(t, 0.0001), "y": snappedf(y - h * 0.5, 0.01), "w": w, "h": snappedf(h, 0.01), "k": k_kind})
	if has_door:
		var dk := {"house": "door", "garage": "garage", "barn": "barn", "none": "door_dark"}.get(door, "door") as String
		out.append({"e": e, "t": snappedf(door_t, 0.0001), "y": 0.0, "w": door_w, "h": snappedf(door_h, 0.01), "k": dk})
	return out


## Where an opening really is on a wall of `length` x `wall_h`: squeezed inside it (the data keeps what the author
## set). {s (centre, metres along), y (bottom), w, h}, or {} when it does not fit at all.
static func fit_opening(o: Dictionary, length: float, wall_h: float) -> Dictionary:
	var kind: Dictionary = OPENING_KINDS.get(String(o.get("k", "win")), OPENING_KINDS["win"])
	var w := float(o.get("w", kind["w"]))
	var h := float(o.get("h", kind["h"]))
	if w > length - 0.1 or h > wall_h - 0.05:
		return {}
	return {"s": clampf(float(o.get("t", 0.5)) * length, w * 0.5 + 0.05, length - w * 0.5 - 0.05),
		"y": clampf(float(o.get("y", kind["y"])), 0.0, wall_h - h - 0.05), "w": w, "h": h}


## Draws openings on one wall, squeezed inside it.
func _draw_openings(list: Array, e: int, a0: Vector3, b0: Vector3, out_n: Vector3, length: float, wall_h: float) -> void:
	var along := (b0 - a0) / length
	for o in list:
		if int(o.get("e", -1)) != e:
			continue
		var fit := fit_opening(o, length, wall_h)
		if fit.is_empty():
			continue
		var kind: Dictionary = OPENING_KINDS.get(String(o.get("k", "win")), OPENING_KINDS["win"])
		var h := float(fit["h"])
		_panel(String(kind["mat"]), a0 + along * float(fit["s"]) + out_n * 0.03 + Vector3(0.0, float(fit["y"]) + h * 0.5, 0.0),
			along, float(fit["w"]), h, out_n)
		stats["windows"] += 1


func _panel(key: String, centre: Vector3, along: Vector3, w: float, h: float, out_n: Vector3) -> void:
	var half := along * (w * 0.5)
	var up_half := Vector3(0, h * 0.5, 0)
	lp.quad_out(key, centre - half - up_half, centre + half - up_half, centre + half + up_half, centre - half + up_half,
		Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Color.WHITE, Color.WHITE, out_n)


func _roof(ring: PackedVector2Array, arch: Dictionary, id: int, wall_h: float, tint: Color, wall_key: String,
		ridge_flip: bool, res: Dictionary) -> void:
	var roof_type := String(arch["roof"])
	if roof_type == "none":
		stats["none"] += 1
		return
	if roof_type == "flat":
		_flat_roof(ring, wall_h, String(arch["roof_mat"]))
		return
	if fill_ratio(ring) < GABLE_FILL_MIN:
		# an L-shaped or ragged footprint: no sloped roof fits it (the editor's "rectangle" fixes that)
		res["irregular"] = true
		res["roof"] = "flat"
		stats["irregular"] += 1
		_flat_roof(ring, wall_h, "roof_flat")
		return
	var b := obr(ring)
	var e1: Vector2 = b["e1"]
	var e2: Vector2 = b["e2"]
	if ridge_flip:
		var old := e1
		e1 = e2
		e2 = -old
		var ext := _extent(ring, e1, e2)
		b = {"smin": ext[0], "smax": ext[1], "tmin": ext[2], "tmax": ext[3]}
	var smin: float = b["smin"]
	var smax: float = b["smax"]
	var tmin: float = b["tmin"]
	var tmax: float = b["tmax"]
	var lx := smax - smin
	var ly := tmax - tmin
	if ly < 2.0:
		_flat_roof(ring, wall_h, "roof_flat")
		res["roof"] = "flat"
		return
	var rise := minf(ly * 0.5 * float(arch["pitch"]), float(arch["max_rise"]))
	var pitch := rise / (ly * 0.5)
	var ov := 0.4
	var cs := (smin + smax) * 0.5
	var ct := (tmin + tmax) * 0.5
	var rh := wall_h + rise
	var ye := wall_h - ov * pitch
	var te := ly * 0.5 + ov
	var key := String(arch["roof_mat"])
	var slope_len := Vector2(te, rh - ye).length()
	var e1_3 := Vector3(e1.x, 0.0, e1.y)
	var e2_3 := Vector3(e2.x, 0.0, e2.y)
	var rv := slope_len / ROOF_TILE
	var c_eave := Color(0.82, 0.80, 0.80)
	res["top"] = rh
	res["ridge_dir"] = e1
	if roof_type == "hip":
		stats["hip"] += 1
		var half_ridge := maxf(lx * 0.5 - ly * 0.5, 0.0)
		var s0 := cs - lx * 0.5 - ov
		var s1 := cs + lx * 0.5 + ov
		var r0 := cs - half_ridge
		var r1 := cs + half_ridge
		for side in [1.0, -1.0]:
			var out_n := (UP + e2_3 * pitch * float(side)).normalized()
			lp.quad_out(key, _rp(e1, e2, ct, s0, float(side) * te, ye), _rp(e1, e2, ct, s1, float(side) * te, ye),
				_rp(e1, e2, ct, r1 + 0.001, 0.0, rh), _rp(e1, e2, ct, r0 - 0.001, 0.0, rh),
				Vector2(s0 / ROOF_TILE, rv), Vector2(s1 / ROOF_TILE, rv), Vector2(r1 / ROOF_TILE, 0), Vector2(r0 / ROOF_TILE, 0),
				c_eave, Color.WHITE, out_n)
		for end in [-1.0, 1.0]:
			var es := s1 if end > 0.0 else s0
			var rs := r1 if end > 0.0 else r0
			var out_e := (UP + e1_3 * pitch * float(end)).normalized()
			lp.tri_out(key, _rp(e1, e2, ct, es, -te, ye), _rp(e1, e2, ct, es, te, ye), _rp(e1, e2, ct, rs, 0.0, rh),
				Vector2(-te / ROOF_TILE, rv), Vector2(te / ROOF_TILE, rv), Vector2(0, 0), c_eave, c_eave, Color.WHITE, out_e)
	else:
		stats["gable"] += 1
		var ov_end := 0.3
		var s0 := cs - lx * 0.5 - ov_end
		var s1 := cs + lx * 0.5 + ov_end
		for side in [1.0, -1.0]:
			var out_n := (UP + e2_3 * pitch * float(side)).normalized()
			lp.quad_out(key, _rp(e1, e2, ct, s0, float(side) * te, ye), _rp(e1, e2, ct, s1, float(side) * te, ye),
				_rp(e1, e2, ct, s1, 0.0, rh), _rp(e1, e2, ct, s0, 0.0, rh),
				Vector2(s0 / ROOF_TILE, rv), Vector2(s1 / ROOF_TILE, rv), Vector2(s1 / ROOF_TILE, 0), Vector2(s0 / ROOF_TILE, 0),
				c_eave, Color.WHITE, out_n)
		# gable end walls, with an attic window when there is room for one
		for end_s in [cs - lx * 0.5, cs + lx * 0.5]:
			var sgn := 1.0 if end_s > cs else -1.0
			lp.tri_out(wall_key, _rp(e1, e2, ct, end_s, -ly * 0.5, wall_h), _rp(e1, e2, ct, end_s, ly * 0.5, wall_h),
				_rp(e1, e2, ct, end_s, 0.0, rh),
				Vector2(0, 0), Vector2(ly / WALL_TILE, 0), Vector2(ly / WALL_TILE * 0.5, -rise / WALL_TILE),
				tint, tint, tint, e1_3 * sgn)
			if rise >= 2.4 and String(arch["windows"]) in ["house", "small", "holes"]:
				var wkey := "c_black" if String(arch["windows"]) == "holes" else "win"
				var hy := minf(rise * 0.32, 1.3)
				var c := _rp(e1, e2, ct, end_s, 0.0, wall_h + hy) + e1_3 * sgn * 0.03
				_panel(wkey, c, e2_3, 0.8, 1.0, e1_3 * sgn)
				stats["windows"] += 1
	if bool(arch.get("chimney", false)) and absi(id) % 5 < 3:
		var cp := _rp(e1, e2, ct, cs + lx * 0.25 * (1.0 if id % 2 == 0 else -1.0), 0.0, rh)
		lp.box("brick", cp + Vector3(0, 0.3, 0), Vector3(0.6, 1.5, 0.6), 1.0)
		res["top"] = rh + 1.05


## Roof point from ridge-frame coordinates: s along the ridge, t across it (from the footprint's centre line).
static func _rp(e1: Vector2, e2: Vector2, ct: float, s: float, t: float, y: float) -> Vector3:
	var q := e1 * s + e2 * (ct + t)
	return Vector3(q.x, y, q.y)


func _flat_roof(ring: PackedVector2Array, wall_h: float, key: String) -> void:
	stats["flat"] += 1
	var idx := Geometry2D.triangulate_polygon(ring)
	if idx.is_empty():
		stats["roof_fail"] += 1
		return
	for i in range(0, idx.size(), 3):
		var p0 := ring[idx[i]]
		var p1 := ring[idx[i + 1]]
		var p2 := ring[idx[i + 2]]
		lp.tri_out(key, Vector3(p0.x, wall_h, p0.y), Vector3(p1.x, wall_h, p1.y), Vector3(p2.x, wall_h, p2.y),
			p0 / ROOF_TILE, p1 / ROOF_TILE, p2 / ROOF_TILE, Color.WHITE, Color.WHITE, Color.WHITE, UP)
