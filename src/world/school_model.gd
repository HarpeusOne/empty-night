class_name SchoolModel
extends RefCounted

## The school complex of Linia, modelled by eye from the reference photos in `src/key buildings/school/` and fitted
## to the two OSM footprints (the old school and the "gym"). See docs/key-buildings/school.md.
##
## Local frame (metres): s along the gym towards its glazed north gable, t across it towards the street (Szkolna,
## east), y up. Origin = the south-west corner of the gym footprint. Everything on the plan comes from OSM; heights,
## window rows and colours are read off the photos and are estimates for the author to correct.
##
##   t < 0: the OLD SCHOOL, white, flat roofs (2 storeys, the south wing and the entrance link 1 storey)
##   t 0..18.7, s 0..14: the NEW WING, 3 storeys under an arched roof, gable with an orange strip facing south
##   t 18.7..24.9, s 0..14: the porch with columns, outdoor stairs and a balcony, the stair block behind it
##   s 14..61.4: the SPORTS HALL, arched brown roof, pilasters and big windows, stepped glazing in the north gable

const ORIGIN_EN := Vector2(-90.440, 180.744)    # (east, north), the gym footprint's south-west corner
const HEADING_DEG := 105.3                      # +s as a compass-free angle from east, counter-clockwise
const TILE := 2.0
const ROOF_TILE := 2.0         # the sheet texture has 4 ribs per tile: a rib every 0.5 m
const UP := Vector3.UP
const BOTTOM := Color(0.66, 0.64, 0.62)
const WHITE := Color(1.0, 1.0, 1.0)
const ARC_SEG := 16

# materials (keys of BlockoutLevel.materials)
const BEIGE := "s_beige"
const ORANGE := "s_orange"
const PLINTH := "s_plinth"
const WHITE_WALL := "s_white"
const GREY := "s_grey"
const ROOF := "s_roof"
const ROOF_WING := "s_roof_wing"
const CLAD := "s_clad"
const FASCIA := "s_fascia"
const WIN := "s_win"
const WIN_OLD := "s_win_old"
const GLAZING := "s_glazing"
const FRAME := "s_frame"
const DOOR := "s_door"
const RAIL := "s_rail"
const FLAT := "roof_flat"
const CHIMNEY := "s_brick"
const KITCHEN_DOOR := "s_door_plain"
const STEPS := "s_steps"

# plan (from the OSM footprints)
const HALL_S0 := 14.0          # where the wing ends and the hall begins (estimate)
const HALL_S1 := 61.4
const HALL_T1 := 24.9
const WING_T1 := 18.7
const PORCH_S1 := 7.2          # the notch in the footprint: the open porch

# heights (estimates from the photos)
const HALL_EAVE := 4.6
const HALL_RISE := 8.6         # top of the hall roof 13.2 m
const WING_SPRING := 7.0
const WING_RISE := 7.4         # top of the wing 14.4 m
const OLD_2 := 7.4             # old school, two storeys
const OLD_1 := 4.2             # one storey: the south wing and the entrance link
const PLINTH_H := 0.6

## The old school as rectangles (s0, s1, t0, t1, height) covering its OSM footprint exactly.
const OLD_PARTS := [
	[-12.3, 35.1, -43.0, -33.3, OLD_2],      # long west wing
	[-1.2, 8.9, -33.3, -25.0, OLD_1],        # low link between the west wing and the kitchen (one storey, 4 windows)
	[-11.2, 2.0, -25.0, -11.6, OLD_1],       # kitchen wing: one storey, roof sloping up to the back, kitchen door
	[2.0, 8.9, -25.0, -22.3, OLD_2],         # spine
	[2.0, 26.7, -22.3, -11.6, OLD_2],        # spine east + north wing
	[8.1, 26.7, -11.6, -8.1, OLD_2],         # north wing, east strip
	[-0.9, 5.5, -11.6, -3.8, OLD_1],         # entrance vestibule, one flat front with the doors at the footway's
	                                         # end; OSM steps this front back twice, the author's photo shows it flat
	[1.9, 5.5, -3.8, 0.0, OLD_1],            # the recess by the new wing, under a small lean-to roof
]
## The vestibule front as the author's photo shows it (rounds 2 and 3): flat at s = -0.92 from the kitchen wing to
## t = -3.76. The footprint used for collision gets the same shape (see footprint_en): OSM vertices dropped and moved,
## in the local frame.
const RING_DROP := [Vector2(2.04, -8.55), Vector2(2.04, -11.65), Vector2(0.23, -6.08), Vector2(-0.93, -6.08)]
const RING_MOVE := [[Vector2(-0.92, -8.55), Vector2(-0.92, -11.65)], [Vector2(0.23, -3.76), Vector2(-0.92, -3.76)]]
const ENTRANCE_DOOR_T := -6.1      # the footway from the gate ends here
const PORCH_T0 := -7.7             # the entrance canopy over the doors and one window, across t
const PORCH_T1 := -3.8
const PORCH_FRONT := -4.6          # how far out it reaches (s)
const KITCHEN := 2             # the part with the single-pitch roof (author's photo, 2026-11-08)
const KITCHEN_BACK := 6.0      # its roof rises from OLD_1 at the front to this at the back
const LINK_PARTS := [6, 7]   # the entrance link: in the colours of the new wing and the hall
## Sides drawn by hand instead of the automatic window rows: "part:side" (side = s0, s1, t0, t1).
const SPECIAL_SIDES := {"0:s0": "stripe", "2:s0": "kitchen", "6:s0": "entrance"}

var lp: LowPoly
var u := Vector2.RIGHT         # +s as (east, north)
var v := Vector2.UP            # +t as (east, north)


func _init(p_lp: LowPoly) -> void:
	lp = p_lp
	var a := deg_to_rad(HEADING_DEG)
	u = Vector2(cos(a), sin(a))
	v = Vector2(u.y, -u.x)       # u turned 90 degrees clockwise: towards the street


## Local (s, t, y) -> Godot position (x = east, z = -north).
func pt(s: float, t: float, y: float) -> Vector3:
	var p := ORIGIN_EN + u * s + v * t
	return Vector3(p.x, y, -p.y)


func dir(ds: float, dt: float) -> Vector3:
	var d := u * ds + v * dt
	return Vector3(d.x, 0.0, -d.y)


## The two OSM footprints, in Godot (x, z) - used for collision and picking by the level.
static func ring_godot(ring_en: Array) -> PackedVector2Array:
	ring_en = footprint_en(ring_en)
	var out := PackedVector2Array()
	for p in ring_en:
		out.append(Vector2(p[0], -p[1]))
	return out


## The old school's OSM ring with the vestibule front made flat (RING_DROP, RING_MOVE). Other rings pass unchanged.
static func footprint_en(ring_en: Array) -> Array:
	var a := deg_to_rad(HEADING_DEG)
	var uu := Vector2(cos(a), sin(a))
	var vv := Vector2(uu.y, -uu.x)
	var out: Array = []
	var changed := false
	for p in ring_en:
		var d := Vector2(float(p[0]), float(p[1])) - ORIGIN_EN
		var l := Vector2(d.dot(uu), d.dot(vv))
		var drop := false
		for q in RING_DROP:
			if l.distance_to(q) < 0.3:
				drop = true
		if drop:
			changed = true
			continue
		var moved := false
		for m in RING_MOVE:
			if l.distance_to(m[0]) < 0.3:
				var c: Vector2 = ORIGIN_EN + uu * m[1].x + vv * m[1].y
				out.append([c.x, c.y])
				moved = true
		if moved:
			changed = true
			continue
		out.append(p)
	return out if changed else ring_en


# ------------------------------------------------------------------ primitives

func wall(key: String, s0: float, t0: float, s1: float, t1: float, y0: float, y1: float, out: Vector2,
		off: float = 0.0, tile: float = TILE, c_bot: Color = BOTTOM, c_top: Color = WHITE) -> void:
	var o := out.normalized()
	var a := Vector2(s0, t0) + o * off
	var b := Vector2(s1, t1) + o * off
	var length := a.distance_to(b)
	lp.quad_out(key, pt(a.x, a.y, y0), pt(b.x, b.y, y0), pt(b.x, b.y, y1), pt(a.x, a.y, y1),
		Vector2(0, -y0 / tile), Vector2(length / tile, -y0 / tile), Vector2(length / tile, -y1 / tile), Vector2(0, -y1 / tile),
		c_bot, c_top, dir(o.x, o.y))


## A textured rectangle in front of a wall (the whole texture stretched over it).
func opening(key: String, s: float, t: float, y_center: float, w: float, h: float, out: Vector2, off: float = 0.04,
		tiles: Vector2 = Vector2.ONE) -> void:
	var o := out.normalized()
	var c := pt(s + o.x * off, t + o.y * off, y_center)
	var o3 := dir(o.x, o.y)
	var right := Vector3(o3.z, 0.0, -o3.x).normalized() * (w * 0.5)
	var up_half := Vector3(0.0, h * 0.5, 0.0)
	lp.quad_out(key, c - right - up_half, c + right - up_half, c + right + up_half, c - right + up_half,
		Vector2(0, tiles.y), Vector2(tiles.x, tiles.y), Vector2(tiles.x, 0), Vector2(0, 0), WHITE, WHITE, o3)


func box(key: String, s0: float, s1: float, t0: float, t1: float, y0: float, y1: float, tile: float = TILE,
		top_key: String = "") -> void:
	wall(key, s0, t0, s1, t0, y0, y1, Vector2(0, -1), 0.0, tile)
	wall(key, s1, t0, s1, t1, y0, y1, Vector2(1, 0), 0.0, tile)
	wall(key, s1, t1, s0, t1, y0, y1, Vector2(0, 1), 0.0, tile)
	wall(key, s0, t1, s0, t0, y0, y1, Vector2(-1, 0), 0.0, tile)
	flat(top_key if top_key != "" else key, s0, s1, t0, t1, y1, tile)


func flat(key: String, s0: float, s1: float, t0: float, t1: float, y: float, tile: float = TILE, down: bool = false) -> void:
	lp.quad_out(key, pt(s0, t0, y), pt(s1, t0, y), pt(s1, t1, y), pt(s0, t1, y),
		Vector2(s0 / tile, t0 / tile), Vector2(s1 / tile, t0 / tile), Vector2(s1 / tile, t1 / tile), Vector2(s0 / tile, t1 / tile),
		WHITE, WHITE, -UP if down else UP)


## Points of an arch across t0..t1 springing at `ys` with `rise`: [Vector2(t, y)] from t1 to t0, and the outward
## normals in (t, y). An elliptical arch: the photos show it flatter than a half circle on the wing, fuller on the hall.
func arch(t0: float, t1: float, ys: float, rise: float, grow: float = 0.0) -> Array:
	var tm := (t0 + t1) * 0.5
	var half := (t1 - t0) * 0.5
	var pts: Array = []
	var nrm: Array = []
	for i in range(ARC_SEG + 1):
		var th := PI * float(i) / ARC_SEG
		var n := Vector2(cos(th) / half, sin(th) / rise).normalized()
		pts.append(Vector2(tm + half * cos(th), ys + rise * sin(th)) + n * grow)
		nrm.append(n)
	return [pts, nrm]


## Arched (barrel) roof along s; `ov` sticks out over both gables. Each gable gets a dark rim (the sheet's edge).
func barrel(key: String, s0: float, s1: float, t0: float, t1: float, ys: float, rise: float, ov: float = 0.3,
		rim0: bool = true, rim1: bool = true) -> void:
	var a := arch(t0, t1, ys, rise, 0.05)
	var pts: Array = a[0]
	var nrm: Array = a[1]
	var arc := 0.0
	var sa := s0 - ov
	var sb := s1 + ov
	for i in range(ARC_SEG):
		var p: Vector2 = pts[i]
		var q: Vector2 = pts[i + 1]
		var seg := p.distance_to(q)
		var n_p: Vector2 = nrm[i]
		var n_q: Vector2 = nrm[i + 1]
		var np3 := (dir(0.0, n_p.x) + UP * n_p.y).normalized()
		var nq3 := (dir(0.0, n_q.x) + UP * n_q.y).normalized()
		var v0 := arc / ROOF_TILE
		var v1 := (arc + seg) / ROOF_TILE
		var c0 := WHITE if n_p.y > 0.3 else Color(0.85, 0.85, 0.85)
		var c1 := WHITE if n_q.y > 0.3 else Color(0.85, 0.85, 0.85)
		lp.tri(key, pt(sa, p.x, p.y), pt(sb, p.x, p.y), pt(sb, q.x, q.y), Vector2(sa / ROOF_TILE, v0), Vector2(sb / ROOF_TILE, v0),
			Vector2(sb / ROOF_TILE, v1), c0, c0, c1, np3, np3, nq3)
		lp.tri(key, pt(sa, p.x, p.y), pt(sb, q.x, q.y), pt(sa, q.x, q.y), Vector2(sa / ROOF_TILE, v0), Vector2(sb / ROOF_TILE, v1),
			Vector2(sa / ROOF_TILE, v1), c0, c1, c1, np3, nq3, nq3)
		# underside, seen from below where the roof overhangs a gable
		lp.quad_out(FASCIA, pt(sa, p.x, p.y - 0.06), pt(sb, p.x, p.y - 0.06), pt(sb, q.x, q.y - 0.06), pt(sa, q.x, q.y - 0.06),
			Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5),
			-(np3 + nq3).normalized())
		for end in [[rim0, sa, -1.0], [rim1, sb, 1.0]]:
			if not bool(end[0]):
				continue
			var se := float(end[1])
			var lo_p: Vector2 = p - n_p * 0.28
			var lo_q: Vector2 = q - n_q * 0.28
			lp.quad_out(FASCIA, pt(se, lo_p.x, lo_p.y), pt(se, lo_q.x, lo_q.y), pt(se, q.x, q.y), pt(se, p.x, p.y),
				Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), WHITE, WHITE, dir(float(end[2]), 0.0))
		arc += seg


## The arched part of a gable wall at s (from `ys` up to the arch), as a fan. `out_sign` = +1 faces +s.
func gable_arch(key: String, s: float, t0: float, t1: float, ys: float, rise: float, out_sign: float, tile: float = TILE) -> void:
	var a := arch(t0, t1, ys, rise)
	var pts: Array = a[0]
	var tm := (t0 + t1) * 0.5
	var n := dir(out_sign, 0.0)
	for i in range(ARC_SEG):
		var p: Vector2 = pts[i]
		var q: Vector2 = pts[i + 1]
		lp.tri_out(key, pt(s, tm, ys), pt(s, p.x, p.y), pt(s, q.x, q.y),
			Vector2(tm / tile, -ys / tile), Vector2(p.x / tile, -p.y / tile), Vector2(q.x / tile, -q.y / tile), WHITE, WHITE, WHITE, n)


## Height of an arch at t (or -1 outside it).
static func arch_y(t: float, t0: float, t1: float, ys: float, rise: float) -> float:
	var tm := (t0 + t1) * 0.5
	var half := (t1 - t0) * 0.5
	var k := (t - tm) / half
	if absf(k) >= 1.0:
		return -1.0
	return ys + rise * sqrt(1.0 - k * k)


## Row of windows along a wall between s0 and s1 (or t0..t1), `count` evenly spaced.
func window_row(key: String, a: Vector2, b: Vector2, out: Vector2, count: int, y_center: float, w: float, h: float,
		off: float = 0.05) -> void:
	for k in range(count):
		var f := (float(k) + 0.5) / count
		var p := a.lerp(b, f)
		opening(key, p.x, p.y, y_center, w, h, out, off)


# ------------------------------------------------------------------ the school

func build() -> void:
	_hall()
	_wing()
	_porch()
	_old_school()
	_entrance_canopy()


## The sports hall: long walls with pilasters and big windows, an arched brown roof, the glazed north gable.
func _hall() -> void:
	var s0 := HALL_S0
	var s1 := HALL_S1
	# long walls
	for side in [[0.0, Vector2(0, -1)], [HALL_T1, Vector2(0, 1)]]:
		var t := float(side[0])
		var o: Vector2 = side[1]
		wall(BEIGE, s0, t, s1, t, 0.0, HALL_EAVE, o)
		wall(PLINTH, s0, t, s1, t, 0.0, PLINTH_H + 0.4, o, 0.04)
		var bays := 12
		var bay := (s1 - s0) / bays
		for k in range(bays + 1):
			var sp := s0 + k * bay
			var tt := t + o.y * 0.12
			box(ORANGE, sp - 0.35, sp + 0.35, minf(t, tt), maxf(t, tt), 0.0, HALL_EAVE - 0.15)
		for k in range(bays):
			var sc := s0 + (k + 0.5) * bay
			var door_here := t > 1.0 and (k == bays - 2 or k == 1)
			if door_here:
				opening(DOOR, sc, t, 1.25, 1.8, 2.5, o, 0.06)
				_small_canopy(sc, t, o)
			else:
				opening(WIN, sc, t, 2.35, 2.5, 2.2, o, 0.06)
		# frieze under the eaves
		wall(BEIGE, s0, t, s1, t, HALL_EAVE - 0.6, HALL_EAVE, o, 0.16)
	# roof and gables
	barrel(ROOF, s0, s1, 0.0, HALL_T1, HALL_EAVE, HALL_RISE, 0.35)
	_hall_north_gable()
	# the south gable shows above and beside the wing
	wall(BEIGE, s0, HALL_T1, s0, 0.0, 0.0, HALL_EAVE, Vector2(-1, 0))
	gable_arch(BEIGE, s0, 0.0, HALL_T1, HALL_EAVE, HALL_RISE, -1.0)
	# two skylights on each side near the wing
	for sk in [20.0, 31.0]:
		for th in [0.62, 2.52]:
			_skylight(sk, 0.0, HALL_T1, HALL_EAVE, HALL_RISE, th, 3.2, 1.6)


func _hall_north_gable() -> void:
	var s := HALL_S1
	var o := Vector2(1, 0)
	wall(BEIGE, s, 0.0, s, HALL_T1, 0.0, HALL_EAVE, o)
	wall(PLINTH, s, 0.0, s, HALL_T1, 0.0, PLINTH_H + 0.4, o, 0.04)
	for tp in [0.0, 6.2, 12.45, 18.7, HALL_T1]:
		box(ORANGE, s, s + 0.12, tp - 0.35, tp + 0.35, 0.0, HALL_EAVE - 0.15)
	gable_arch(CLAD, s, 0.0, HALL_T1, HALL_EAVE, HALL_RISE, 1.0, 1.0)
	# the stepped glazing: rows of panes, widest at the bottom, in a dark frame
	var pane := 1.1
	var rows := [8, 8, 6, 6, 4, 4, 2]
	var tm := HALL_T1 * 0.5
	for r in range(rows.size()):
		var y0 := HALL_EAVE + 0.1 + r * pane
		var n := int(rows[r])
		var top_ok := arch_y(tm + n * pane * 0.5 + 0.2, 0.0, HALL_T1, HALL_EAVE, HALL_RISE)
		while n > 1 and top_ok < y0 + pane + 0.15:
			n -= 2
			top_ok = arch_y(tm + n * pane * 0.5 + 0.2, 0.0, HALL_T1, HALL_EAVE, HALL_RISE)
		var w := n * pane
		opening(FRAME, s, tm, y0 + pane * 0.5, w + 0.24, pane + 0.24, o, 0.05)
		opening(GLAZING, s, tm, y0 + pane * 0.5, w, pane, o, 0.08, Vector2(n, 1))


func _skylight(s: float, t0: float, t1: float, ys: float, rise: float, th: float, length: float, width: float) -> void:
	var tm := (t0 + t1) * 0.5
	var half := (t1 - t0) * 0.5
	var c := Vector2(tm + half * cos(th), ys + rise * sin(th))
	var n := Vector2(cos(th) / half, sin(th) / rise).normalized()
	var along := Vector2(-n.y, n.x)          # tangent of the arch in (t, y)
	var a := c - along * width * 0.5 + n * 0.12
	var b := c + along * width * 0.5 + n * 0.12
	var n3 := (dir(0.0, n.x) + UP * n.y).normalized()
	lp.quad_out(GLAZING, pt(s - length * 0.5, a.x, a.y), pt(s + length * 0.5, a.x, a.y), pt(s + length * 0.5, b.x, b.y),
		pt(s - length * 0.5, b.x, b.y), Vector2(0, 1), Vector2(2, 1), Vector2(2, 0), Vector2(0, 0), WHITE, WHITE, n3)


## The little curved canopy over a side door of the hall.
func _small_canopy(sc: float, t: float, o: Vector2) -> void:
	var depth := 1.0
	var t_out := t + o.y * depth
	var y := 2.85
	for k in range(4):
		var f0 := float(k) / 4.0
		var f1 := float(k + 1) / 4.0
		var y0 := y + 0.25 * sin(f0 * PI * 0.5 + PI * 0.5)
		var y1 := y + 0.25 * sin(f1 * PI * 0.5 + PI * 0.5)
		var ta := lerpf(t, t_out, f0)
		var tb := lerpf(t, t_out, f1)
		lp.quad_out(ROOF, pt(sc - 1.4, ta, y0), pt(sc + 1.4, ta, y0), pt(sc + 1.4, tb, y1), pt(sc - 1.4, tb, y1),
			Vector2(0, 0), Vector2(2.8, 0), Vector2(2.8, 0.3), Vector2(0, 0.3), WHITE, WHITE, UP)
		lp.quad_out(FASCIA, pt(sc - 1.4, ta, y0 - 0.05), pt(sc + 1.4, ta, y0 - 0.05), pt(sc + 1.4, tb, y1 - 0.05),
			pt(sc - 1.4, tb, y1 - 0.05), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), WHITE, WHITE, -UP)


## The new wing: three storeys, an arched roof, the south gable with the orange window strip.
func _wing() -> void:
	var s1 := HALL_S0
	var tw := WING_T1
	# side walls up to the springing of the arch
	wall(BEIGE, 0.0, 0.0, s1, 0.0, 0.0, WING_SPRING, Vector2(0, -1))
	wall(BEIGE, s1, tw, PORCH_S1, tw, 0.0, WING_SPRING, Vector2(0, 1))
	wall(BEIGE, PORCH_S1, tw, 0.0, tw, 0.0, WING_SPRING, Vector2(0, 1))
	for side in [[0.0, Vector2(0, -1)], [tw, Vector2(0, 1)]]:
		var t := float(side[0])
		var o: Vector2 = side[1]
		wall(PLINTH, 0.0, t, s1, t, 0.0, PLINTH_H, o, 0.04)
		box(ORANGE, -0.1, 0.6, minf(t, t + o.y * 0.12), maxf(t, t + o.y * 0.12), 0.0, WING_SPRING)
	# west side: two rows of windows (the entrance link covers the ground floor at s 1.9..5.5)
	for y in [1.7, 5.0]:
		window_row(WIN, Vector2(0.5, 0.0), Vector2(s1, 0.0), Vector2(0, -1), 3, y, 1.3, 1.6)
	# east side: the porch covers s 0..7.2, the windows there look onto it
	for y in [1.7, 5.0]:
		window_row(WIN, Vector2(0.4, tw), Vector2(PORCH_S1, tw), Vector2(0, 1), 2, y, 1.2, 1.6)
	# the south gable
	wall(BEIGE, 0.0, tw, 0.0, 0.0, 0.0, WING_SPRING, Vector2(-1, 0))
	gable_arch(BEIGE, 0.0, 0.0, tw, WING_SPRING, WING_RISE, -1.0)
	wall(PLINTH, 0.0, tw, 0.0, 0.0, 0.0, PLINTH_H, Vector2(-1, 0), 0.04)
	# the orange strip with three windows (off centre, as on the photos)
	var tc := 7.1
	var top := arch_y(tc + 1.3, 0.0, tw, WING_SPRING, WING_RISE) - 0.1
	box(ORANGE, -0.1, 0.0, tc - 1.3, tc + 1.3, 0.0, top)
	for yc in [3.0, 6.6, 10.4]:
		opening(WIN, 0.0, tc, yc, 0.95, 1.45, Vector2(-1, 0), 0.14)
		box(RAIL, -0.22, -0.16, tc - 0.5, tc + 0.5, yc - 0.75, yc - 0.7)   # the little window guard
		box(RAIL, -0.22, -0.16, tc - 0.5, tc + 0.5, yc - 0.35, yc - 0.3)
	for yp in [[PLINTH_H, 2.1], [3.85, 5.75], [7.45, 9.55], [11.25, top]]:
		box(BEIGE, -0.16, -0.1, tc - 0.75, tc + 0.75, float(yp[0]), float(yp[1]))
	box(ORANGE, -0.1, 0.0, tw - 0.65, tw, 0.0, WING_SPRING)    # corner pilasters
	box(ORANGE, -0.1, 0.0, 0.0, 0.65, 0.0, WING_SPRING)
	# a window high up near the corner (the third storey under the arch)
	opening(WIN, 0.0, 14.2, 9.0, 0.95, 1.3, Vector2(-1, 0), 0.06)
	# the north gable of the wing shows above the hall roof
	gable_arch(BEIGE, s1, 0.0, tw, WING_SPRING, WING_RISE, 1.0)
	wall(BEIGE, s1, 0.0, s1, tw, HALL_EAVE, WING_SPRING, Vector2(1, 0))
	barrel(ROOF_WING, 0.0, s1, 0.0, tw, WING_SPRING, WING_RISE, 0.35, true, false)
	for sk in [3.5, 9.5]:
		for th in [0.75, 2.39]:
			_skylight(sk, 0.0, tw, WING_SPRING, WING_RISE, th, 1.6, 1.4)
	# chimney at the top, just behind the south gable
	box(CHIMNEY, 1.0, 2.3, 8.6, 10.0, WING_SPRING + WING_RISE - 1.0, WING_SPRING + WING_RISE + 1.1, 1.0)


## The stair block behind the porch and the open porch itself: four columns, a first-floor balcony with a
## rail, outdoor stairs up to it along the street side, a flat roof under the wing's eaves.
func _porch() -> void:
	var t0 := WING_T1
	var t1 := HALL_T1
	var s1 := HALL_S0
	var h := WING_SPRING - 0.4
	box(BEIGE, PORCH_S1, s1, t0, t1, 0.0, h, TILE, FLAT)
	wall(PLINTH, PORCH_S1, t1, s1, t1, 0.0, PLINTH_H, Vector2(0, 1), 0.04)
	wall(PLINTH, PORCH_S1, t0, PORCH_S1, t1, 0.0, PLINTH_H, Vector2(-1, 0), 0.04)
	wall(FASCIA, PORCH_S1, t1, s1, t1, h - 0.45, h, Vector2(0, 1), 0.06)
	for y in [1.7, 5.0]:
		window_row(WIN, Vector2(PORCH_S1, t1), Vector2(s1, t1), Vector2(0, 1), 2, y, 1.3, 1.6)
	opening(DOOR, PORCH_S1, t0 + 2.6, 1.25, 1.8, 2.5, Vector2(-1, 0), 0.05)
	opening(DOOR, PORCH_S1, t0 + 2.6, 4.55, 1.6, 2.4, Vector2(-1, 0), 0.05)
	# columns
	for c in [[0.35, t1 - 0.35], [PORCH_S1 - 0.35, t1 - 0.35], [0.35, t0 + 3.1]]:
		box(ORANGE, float(c[0]) - 0.3, float(c[0]) + 0.3, float(c[1]) - 0.3, float(c[1]) + 0.3, 0.0, h)
	# first-floor balcony along the wing wall and a landing at the stair block's upper door
	var yb := 3.3
	var tl := t0 + 3.6           # the balcony's street edge
	var ts := t1 - 0.7           # the stairs' street edge (the corner columns stay outside them)
	var land := PORCH_S1 - 1.3   # the landing starts here
	box(BEIGE, 0.0, PORCH_S1, t0, tl, yb - 0.25, yb, TILE)
	box(BEIGE, land, PORCH_S1, tl, ts, yb - 0.25, yb, TILE)
	# stairs from the ground at the open south end (s = 0.4, by the footway) up to the landing
	var steps := 18
	var sbot := 0.4
	for k in range(steps):
		var sa := sbot + k * (land - sbot) / steps
		var sb := sa + (land - sbot) / steps
		var y1 := yb * float(k + 1) / steps
		box(BEIGE, sa, sb, tl + 0.05, ts, maxf(y1 - 0.35, 0.0), y1, 1.0)
	# rails (author, round 2: the old ones were too thin to see): balcony edges, landing, both sides of the stairs
	_rail_line(Vector2(0.05, t0 + 0.05), Vector2(0.05, tl), yb, 1.0)
	_rail_line(Vector2(0.05, tl), Vector2(land, tl), yb, 1.0)
	_rail_line(Vector2(land, ts), Vector2(PORCH_S1 - 0.05, ts), yb, 1.0)
	_rail_line(Vector2(sbot, ts), Vector2(land, ts), 0.0, 1.0, yb)
	# roof over the porch, just under the wing's eaves
	box(FASCIA, -0.3, PORCH_S1 + 0.1, t0 - 0.1, t1 + 0.3, h - 0.45, h)
	flat(FLAT, -0.3, PORCH_S1 + 0.1, t0 - 0.1, t1 + 0.3, h + 0.01)
	flat(BEIGE, -0.3, PORCH_S1 + 0.1, t0 - 0.1, t1 + 0.3, h - 0.46, TILE, true)


## A rail: posts, a top bar, a middle bar and thin balusters from a to b (in s, t), at height y (rising to y_end
## along it), red-brown like on the photos.
func _rail_line(a: Vector2, b: Vector2, y: float, height: float, y_end: float = -1.0) -> void:
	if y_end < 0.0:
		y_end = y
	var length := a.distance_to(b)
	var n := maxi(int(length / 1.2), 1)
	for k in range(n + 1):
		var f := float(k) / n
		var p := a.lerp(b, f)
		var yp := lerpf(y, y_end, f)
		box(RAIL, p.x - 0.05, p.x + 0.05, p.y - 0.05, p.y + 0.05, yp, yp + height, 1.0)
	var nb := maxi(int(length / 0.22), 1)
	for k in range(1, nb):
		var f := float(k) / nb
		var p := a.lerp(b, f)
		var yp := lerpf(y, y_end, f)
		box(RAIL, p.x - 0.015, p.x + 0.015, p.y - 0.015, p.y + 0.015, yp + 0.1, yp + height, 1.0)
	for bar in [[height, 0.07], [height * 0.5, 0.04]]:
		var hb := float(bar[0])
		var th := float(bar[1])
		var side := Vector2(-(b - a).y, (b - a).x).normalized() * th
		lp.quad_out(RAIL, pt(a.x - side.x, a.y - side.y, y + hb), pt(b.x - side.x, b.y - side.y, y_end + hb),
			pt(b.x + side.x, b.y + side.y, y_end + hb), pt(a.x + side.x, a.y + side.y, y + hb),
			Vector2(0, 0), Vector2(1, 0), Vector2(1, 0.1), Vector2(0, 0.1), WHITE, WHITE, UP)
		for sg in [1.0, -1.0]:
			var sd: Vector2 = side * float(sg)
			lp.quad_out(RAIL, pt(a.x + sd.x, a.y + sd.y, y + hb - th * 2.0), pt(b.x + sd.x, b.y + sd.y, y_end + hb - th * 2.0),
				pt(b.x + sd.x, b.y + sd.y, y_end + hb), pt(a.x + sd.x, a.y + sd.y, y + hb),
				Vector2(0, 0), Vector2(1, 0), Vector2(1, 0.1), Vector2(0, 0.1), WHITE, WHITE, dir(sd.x, sd.y))


## The old school: white walls with grey bands, flat roofs with a brown fascia, rows of windows on the outer walls.
## Walls between two parts are drawn only where one part is taller (the step above the lower roof). The entrance
## link to the new wing has the wing's colours.
func _old_school() -> void:
	var parts: Array = OLD_PARTS.duplicate(true)
	parts[KITCHEN][4] = KITCHEN_BACK      # its roof meets the walls behind it at the high end
	var wing_block := [0.0, HALL_S0, 0.0, WING_T1, 99.0]       # the new wing: no wall where the link touches it
	for i in range(OLD_PARTS.size()):
		var p: Array = OLD_PARTS[i]
		var s0 := float(p[0])
		var s1 := float(p[1])
		var t0 := float(p[2])
		var t1 := float(p[3])
		var h := float(p[4])
		var others: Array = parts.duplicate()
		others.remove_at(i)
		others.append(wing_block)
		# four sides: [line coord, from, to, axis (0 = side at constant t, 1 = at constant s), outward, name]
		var sides := [[t0, s0, s1, 0, Vector2(0, -1), "t0"], [t1, s0, s1, 0, Vector2(0, 1), "t1"],
			[s0, t0, t1, 1, Vector2(-1, 0), "s0"], [s1, t0, t1, 1, Vector2(1, 0), "s1"]]
		for sd in sides:
			_old_side(i, sd, h, others)
		if i == KITCHEN:
			_kitchen_roof(s0, s1, t0, t1, h)
		else:
			flat(FLAT, s0, s1, t0, t1, h)
	# a square ventilation stack on the west wing and a smaller one on the north wing
	box(GREY, -6.5, -4.6, -39.0, -37.1, OLD_2, OLD_2 + 2.6, TILE, GREY)
	box(GREY, 16.0, 17.6, -18.0, -16.4, OLD_2, OLD_2 + 1.6, TILE, GREY)


## One side of an old-school part: split into pieces by the neighbouring parts on the same line.
func _old_side(part: int, sd: Array, h: float, others: Array) -> void:
	var line := float(sd[0])
	var a := float(sd[1])
	var b := float(sd[2])
	var axis := int(sd[3])
	var o: Vector2 = sd[4]
	var link := part in LINK_PARTS
	var special := String(SPECIAL_SIDES.get("%d:%s" % [part, sd[5]], ""))
	# neighbours whose opposite side lies on this line: [from, to, height]
	var cover: Array = []
	for q in others:
		var opp := 0.0
		var qa := 0.0
		var qb := 0.0
		if axis == 0:
			opp = float(q[3]) if o.y < 0.0 else float(q[2])
			qa = float(q[0])
			qb = float(q[1])
		else:
			opp = float(q[1]) if o.x < 0.0 else float(q[0])
			qa = float(q[2])
			qb = float(q[3])
		if absf(opp - line) > 0.05:
			continue
		var lo := maxf(a, qa)
		var hi := minf(b, qb)
		if hi - lo > 0.05:
			cover.append([lo, hi, float(q[4])])
	# cut [a, b] at every neighbour edge
	var cuts := [a, b]
	for c in cover:
		cuts.append(c[0])
		cuts.append(c[1])
	cuts.sort()
	for k in range(cuts.size() - 1):
		var lo := float(cuts[k])
		var hi := float(cuts[k + 1])
		if hi - lo < 0.05:
			continue
		var mid := (lo + hi) * 0.5
		var nh := 0.0
		for c in cover:
			if mid > float(c[0]) and mid < float(c[1]):
				nh = maxf(nh, float(c[2]))
		if nh >= h - 0.01:
			continue
		var p0 := Vector2(lo, line) if axis == 0 else Vector2(line, lo)
		var p1 := Vector2(hi, line) if axis == 0 else Vector2(line, hi)
		wall(BEIGE if link else WHITE_WALL, p0.x, p0.y, p1.x, p1.y, nh, h, o)
		wall(FASCIA, p0.x, p0.y, p1.x, p1.y, h - 0.5, h + 0.15, o, 0.08)
		if nh > 0.0:
			# the upper floor above a lower roof has its windows too (author, round 2)
			if h - nh > 2.8:
				_old_windows(p0, p1, o, h, link, 1)
			continue
		wall(PLINTH if link else GREY, p0.x, p0.y, p1.x, p1.y, 0.0, PLINTH_H, o, 0.03)
		match special:
			"stripe":
				_grey_stripe(p0, p1, o, h)
			"kitchen":
				_kitchen_front(p0, p1, o)
			"entrance":
				_entrance_front(p0, p1, o)
			_:
				_old_windows(p0, p1, o, h, link)


## Rows of windows on an outer wall. On the white school each ground-floor row sits in a grey band.
func _old_windows(p0: Vector2, p1: Vector2, o: Vector2, h: float, link: bool, first_floor: int = 0) -> void:
	var length := p0.distance_to(p1)
	if length < 2.6:
		return
	var floors := 2 if h > 6.0 else 1
	var spacing := 2.7 if floors == 2 else 2.0
	var count := int((length - 0.6) / spacing)
	if count < 1:
		return
	if not link and first_floor == 0:
		wall(GREY, p0.x, p0.y, p1.x, p1.y, 0.95, 2.55, o, 0.02)
	for f in range(first_floor, floors):
		var yc := 1.75 + f * 3.3
		var span := count * spacing
		var a := p0.lerp(p1, (length - span) * 0.5 / length)
		var b := p0.lerp(p1, 1.0 - (length - span) * 0.5 / length)
		window_row(WIN if link else WIN_OLD, a, b, o, count, yc, 1.5, 1.5)


## A blank end wall with a wide grey stripe from the top to the bottom (the west wing's end by the library).
func _grey_stripe(p0: Vector2, p1: Vector2, o: Vector2, h: float) -> void:
	var a := p0.lerp(p1, 0.30)
	var b := p0.lerp(p1, 0.62)
	wall(GREY, a.x, a.y, b.x, b.y, PLINTH_H, h - 0.5, o, 0.02)


## The kitchen front: a window at each side, the kitchen door with red steps in the middle, a grey band,
## a steel ladder up to the roof near the left corner (author's photo).
func _kitchen_front(p0: Vector2, p1: Vector2, o: Vector2) -> void:
	wall(GREY, p0.x, p0.y, p1.x, p1.y, 0.95, 2.55, o, 0.02)
	var mid := p0.lerp(p1, 0.5)
	opening(WIN_OLD, p0.lerp(p1, 0.2).x, p0.lerp(p1, 0.2).y, 1.75, 1.5, 1.5, o, 0.05)
	opening(WIN_OLD, p0.lerp(p1, 0.8).x, p0.lerp(p1, 0.8).y, 1.75, 1.5, 1.5, o, 0.05)
	opening(KITCHEN_DOOR, mid.x, mid.y, 1.3, 1.0, 2.1, o, 0.05)
	for k in range(3):
		var d := o * (0.35 * (3 - k))
		var along := (p1 - p0).normalized() * 0.9
		var c0 := mid - along
		var c1 := mid + along + d
		box(STEPS, minf(c0.x, c1.x), maxf(c0.x, c1.x), minf(c0.y, c1.y), maxf(c0.y, c1.y), 0.0, 0.09 * (k + 1), 1.0)
	# the ladder: two rails and rungs, from the plinth to above the roof
	var lp0 := p0.lerp(p1, 0.08)
	var along2 := (p1 - p0).normalized()
	for side in [-0.25, 0.25]:
		var c := lp0 + along2 * float(side) + o * 0.25
		box(GREY, c.x - 0.03, c.x + 0.03, c.y - 0.03, c.y + 0.03, 0.4, OLD_1 + 1.0, 1.0)
	var y := 0.6
	while y < OLD_1 + 0.8:
		var a := lp0 - along2 * 0.25 + o * 0.25
		var b := lp0 + along2 * 0.25 + o * 0.25
		box(GREY, minf(a.x, b.x) - 0.02, maxf(a.x, b.x) + 0.02, minf(a.y, b.y) - 0.02, maxf(a.y, b.y) + 0.02, y, y + 0.04, 1.0)
		y += 0.3


## The vestibule front under the canopy: the glass doors where the footway ends, a window in the room beside them.
func _entrance_front(p0: Vector2, p1: Vector2, o: Vector2) -> void:
	# a side at constant s, p0 at the lower t (by the kitchen): a window, the doors at the footway, a window
	opening(WIN, p0.x, (p0.y + PORCH_T0) * 0.5, 1.75, 1.8, 1.6, o, 0.05)
	opening(DOOR, p0.x, ENTRANCE_DOOR_T, 1.25, 1.8, 2.5, o, 0.05)
	opening(WIN, p0.x, (ENTRANCE_DOOR_T + 1.2 + PORCH_T1 - 0.25) * 0.5, 1.6, 1.0, 1.9, o, 0.05)


## The kitchen wing's single-pitch roof (low at the front, high at the back) and the triangles it leaves on the
## side walls, with a brown edge along the slope.
func _kitchen_roof(s0: float, s1: float, t0: float, t1: float, h: float) -> void:
	var hb := KITCHEN_BACK
	var rise := hb - h
	var n := (UP + dir(-rise / (s1 - s0), 0.0)).normalized()
	lp.quad_out(FLAT, pt(s0 - 0.3, t0 - 0.3, h - 0.03), pt(s0 - 0.3, t1 + 0.3, h - 0.03), pt(s1, t1 + 0.3, hb), pt(s1, t0 - 0.3, hb),
		Vector2(0, 0), Vector2((t1 - t0) / TILE, 0), Vector2((t1 - t0) / TILE, (s1 - s0) / TILE), Vector2(0, (s1 - s0) / TILE),
		WHITE, WHITE, n)
	for side in [[t0, Vector2(0, -1)], [t1, Vector2(0, 1)]]:
		var t := float(side[0])
		var o: Vector2 = side[1]
		lp.tri_out(WHITE_WALL, pt(s0, t, h), pt(s1, t, h), pt(s1, t, hb), Vector2(s0 / TILE, -h / TILE), Vector2(s1 / TILE, -h / TILE),
			Vector2(s1 / TILE, -hb / TILE), WHITE, WHITE, WHITE, dir(o.x, o.y))
		var tt := t + o.y * 0.3
		lp.quad_out(FASCIA, pt(s0 - 0.3, tt, h - 0.45), pt(s1, tt, hb - 0.45), pt(s1, tt, hb + 0.12), pt(s0 - 0.3, tt, h + 0.12),
			Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), WHITE, WHITE, dir(o.x, o.y))
		# the underside of the overhang (from below the sky showed through between the wall and the edge)
		lp.quad_out(FASCIA, pt(s0 - 0.3, t, h - 0.45), pt(s1, t, hb - 0.45), pt(s1, tt, hb - 0.45), pt(s0 - 0.3, tt, h - 0.45),
			Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Color(0.6, 0.6, 0.6), Color(0.6, 0.6, 0.6), -UP)


## The entrance (author's photo, round 3): a short canopy at right angles to the wall, over the end of the footway.
## Its arched gable faces the path; two orange pillars at the front (the real middle one left out on purpose), a brown beam under the arch; under it the
## doors and one window. Beside it, in the recess by the new wing, a small lean-to roof over a window.
func _entrance_canopy() -> void:
	var sw := -0.9               # the vestibule front
	var sf := PORCH_FRONT
	var t0 := PORCH_T0
	var t1 := PORCH_T1
	var hp := 2.7                # top of the pillars
	var ys := hp + 0.45          # where the arch springs
	var rise := 0.75
	for tc in [t0 + 0.25, t1 - 0.25]:   # the real middle pillar left out (author, round 4)
		box(ORANGE, sf + 0.05, sf + 0.55, float(tc) - 0.25, float(tc) + 0.25, 0.0, hp)
	box(ORANGE, sw - 0.4, sw, t0, t0 + 0.25, 0.0, hp)       # the pillars against the wall
	box(ORANGE, sw - 0.4, sw, t1 - 0.25, t1, 0.0, hp)
	# the beam all round under the arch, the arched gable above it, the roof
	box(FASCIA, sf - 0.05, sf + 0.6, t0, t1, hp, ys)
	box(FASCIA, sf, sw, t0, t0 + 0.2, hp, ys)
	box(FASCIA, sf, sw, t1 - 0.2, t1, hp, ys)
	gable_arch(FASCIA, sf, t0, t1, ys, rise, -1.0)
	barrel(ROOF_WING, sf, sw, t0 - 0.05, t1 + 0.05, ys, rise, 0.25, true, false)
	flat(BEIGE, sf, sw, t0, t1, hp, TILE, true)
	# paving under it, joining the footway to the doors
	flat("dirt", sf - 0.6, sw, t0, t1, 0.085, 4.0)
	# the lean-to in the recess between the vestibule (t = -3.8) and the new wing (t = 0)
	var sr := 1.9
	var so := 0.3
	var yh := 3.3
	var yl := 2.85
	var n := (UP + dir(-(yh - yl) / (sr - so), 0.0)).normalized()
	lp.quad_out(ROOF_WING, pt(so, t1, yl), pt(so, 0.0, yl), pt(sr, 0.0, yh), pt(sr, t1, yh),
		Vector2(t1 / ROOF_TILE, so / ROOF_TILE), Vector2(0.0, so / ROOF_TILE), Vector2(0.0, sr / ROOF_TILE),
		Vector2(t1 / ROOF_TILE, sr / ROOF_TILE), WHITE, WHITE, n)
	lp.quad_out(BEIGE, pt(so, t1, yl - 0.08), pt(sr, t1, yh - 0.08), pt(sr, 0.0, yh - 0.08), pt(so, 0.0, yl - 0.08),
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Color(0.7, 0.7, 0.7), Color(0.7, 0.7, 0.7), -n)
	wall(FASCIA, so, t1, so, 0.0, yl - 0.25, yl + 0.05, Vector2(-1, 0), 0.0, 1.0)
