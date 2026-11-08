class_name MapProps
extends Node3D

## Editable map objects: trees, crosses, benches, shrines (point objects) and cobble / gravel paths, fences,
## walls, hedges (polylines). The data is one JSON list (data/map/props.json) that the in-game map editor
## (MapEditor, F2) changes and saves; this class turns it into meshes + collision.
##
## Item: {"id", "type", "x", "z", "yaw", "s", "y"}          point object (s = size multiplier, yaw in radians, y = height offset)
##       {"id", "type", "pts": [[x, z], ...], "w": width, "y"}  polyline (w only for paths, y = height offset of the whole line)
## World coordinates are Godot metres (x east, z = -north). Local front of a point object is +z.

const PAVE_Y := 0.06
const BASE_H := 0.45
const FENCE_H := 1.45
const POST_SPACING := 3.6
const PAVE_COLOR := Color(0.85, 0.85, 0.85)
## Small things that sit on whatever is under them (a candle on a grave slab) instead of on the ground.
const SITS_ON_TOP := ["candle", "candles"]

## kind: point (one click), line (click points, Enter), area (click the corners of a polygon, Enter closes it).
const TYPES := {
	"conifer": {"label": "Iglak", "kind": "point"},
	"leafy": {"label": "Drzewo liściaste", "kind": "point"},
	"bush_round": {"label": "Krzew kulisty", "kind": "point"},
	"tree_ball": {"label": "Drzewko kuliste", "kind": "point"},
	"cross_wood": {"label": "Krzyż drewniany", "kind": "point"},
	"cross_iron": {"label": "Krzyż żelazny", "kind": "point"},
	"shrine": {"label": "Kapliczka", "kind": "point"},
	"boulder": {"label": "Głaz (pomnik)", "kind": "point"},
	"grave": {"label": "Nagrobek", "kind": "point"},
	"grave_double": {"label": "Nagrobek podwójny", "kind": "point"},
	"candle": {"label": "Znicz", "kind": "point"},
	"candles": {"label": "Znicze (kilka)", "kind": "point"},
	"bench": {"label": "Ławka z oparciem", "kind": "point"},
	"bench_plain": {"label": "Ławka bez oparcia", "kind": "point"},
	"bin": {"label": "Kosz na śmieci", "kind": "point"},
	"notice_board": {"label": "Tablica ogłoszeń", "kind": "point"},
	"path_cobble": {"label": "Ścieżka: kostka szara", "kind": "line", "w": 3.0},
	"path_cobble_red": {"label": "Ścieżka: kostka czerwona", "kind": "line", "w": 0.6},
	"path_cobble_grey": {"label": "Ścieżka: kostka grafit", "kind": "line", "w": 3.0},
	"path_gravel": {"label": "Ścieżka: żwir", "kind": "line", "w": 2.5},
	"path_asphalt": {"label": "Ścieżka: asfalt", "kind": "line", "w": 4.0},
	"fence_brick": {"label": "Płot ceglany", "kind": "line", "w": 0.0},
	"fence_stone": {"label": "Płot kamienny", "kind": "line", "w": 0.0},
	"wall_stone": {"label": "Mur kamienny", "kind": "line", "w": 0.0},
	"hedge": {"label": "Żywopłot: tuje", "kind": "line", "w": 0.0},
	"hedge_box": {"label": "Żywopłot strzyżony", "kind": "line", "w": 0.0},
	"area_cobble": {"label": "Plac: kostka szara", "kind": "area"},
	"area_cobble_red": {"label": "Plac: kostka czerwona", "kind": "area"},
	"area_cobble_grey": {"label": "Plac: kostka grafit", "kind": "area"},
	"area_gravel": {"label": "Plac: żwir", "kind": "area"},
	"area_asphalt": {"label": "Plac: asfalt", "kind": "area"},
}

## Paving surfaces: material key, texture tile (m) and layer. Everything of one material lies at ONE height and
## has its texture in world coordinates, so overlapping paths / areas of the same paving look like one surface
## (no seams, no flicker). A higher layer lies on top (red stripes over grey cobble).
const PAVING := {
	"asphalt": ["road", 4.0, 0], "gravel": ["dirt", 2.0, 1], "cobble": ["g_cobble", 1.0, 2],
	"cobble_grey": ["g_cobble_grey", 1.0, 3], "cobble_red": ["g_cobble_red", 1.0, 4],
}
const PAVE_LAYER_STEP := 0.008

var materials: Dictionary = {}
var items: Array = []                 # Array of Dictionary
var nodes := {}                       # id -> Node3D
var path := ""
var _next_id := 1


static func is_path(type: String) -> bool:
	return type.begins_with("path_")


static func is_area(type: String) -> bool:
	return type.begins_with("area_")


## "cobble_red" for "path_cobble_red" / "area_cobble_red".
static func paving_of(type: String) -> String:
	return type.substr(type.find("_") + 1)


static func pave_y(paving: String) -> float:
	return PAVE_Y + PAVE_LAYER_STEP * float(PAVING.get(paving, PAVING["cobble"])[2])


## A closed smooth loop through the polygon corners (Catmull-Rom), or the corners themselves.
static func sample_closed(pts: Array, smooth: bool, step: float) -> Array:
	if not smooth or pts.size() < 3:
		return pts
	var out: Array = []
	var n := pts.size()
	for i in range(n):
		var p0 := Vector2(pts[(i - 1 + n) % n][0], pts[(i - 1 + n) % n][1])
		var p1 := Vector2(pts[i][0], pts[i][1])
		var p2 := Vector2(pts[(i + 1) % n][0], pts[(i + 1) % n][1])
		var p3 := Vector2(pts[(i + 2) % n][0], pts[(i + 2) % n][1])
		var steps := clampi(int(ceil(p1.distance_to(p2) / maxf(step, 0.2))), 2, 40)
		for j in range(steps):
			var t := float(j) / steps
			var q := (p1 * 2.0 + (p2 - p0) * t + (p0 * 2.0 - p1 * 5.0 + p2 * 4.0 - p3) * t * t
				+ (p1 * 3.0 - p0 - p2 * 3.0 + p3) * t * t * t) * 0.5
			out.append([q.x, q.y])
	return out


## The outline of an area as drawn (closed, not repeating the first point).
static func area_outline(it: Dictionary) -> Array:
	return sample_closed(it["pts"], bool(it.get("smooth", false)), 0.8)


## Points of a line as it is drawn: straight between the control points, or a smooth Catmull-Rom curve through
## them when `smooth` is set (needs 3+ points). `step` = about how far apart the sampled points are (metres).
static func sample(pts: Array, smooth: bool, step: float) -> Array:
	if not smooth or pts.size() < 3:
		return pts
	var out: Array = []
	var n := pts.size()
	for i in range(n - 1):
		var p1 := Vector2(pts[i][0], pts[i][1])
		var p2 := Vector2(pts[i + 1][0], pts[i + 1][1])
		var p0 := Vector2(pts[i - 1][0], pts[i - 1][1]) if i > 0 else p1 * 2.0 - p2
		var p3 := Vector2(pts[i + 2][0], pts[i + 2][1]) if i + 2 < n else p2 * 2.0 - p1
		var steps := clampi(int(ceil(p1.distance_to(p2) / maxf(step, 0.2))), 2, 40)
		for j in range(steps):
			var t := float(j) / steps
			var q := (p1 * 2.0 + (p2 - p0) * t + (p0 * 2.0 - p1 * 5.0 + p2 * 4.0 - p3) * t * t
				+ (p1 * 3.0 - p0 - p2 * 3.0 + p3) * t * t * t) * 0.5
			out.append([q.x, q.y])
	out.append([pts[n - 1][0], pts[n - 1][1]])
	return out


static func kind_of(type: String) -> String:
	return String(TYPES.get(type, {}).get("kind", "point"))


# ------------------------------------------------------------------ data

func load_or_default(file: String, default_items: Array) -> void:
	path = file
	if FileAccess.file_exists(file):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(file))
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("items"):
			items = parsed["items"]
			for it in items:
				_next_id = maxi(_next_id, int(it["id"]) + 1)
			rebuild_all()
			return
		push_warning("MapProps: cannot read %s, using the default layout" % file)
	items = []
	for d in default_items:
		d["id"] = _next_id
		_next_id += 1
		items.append(d)
	rebuild_all()


func to_json() -> String:
	return JSON.stringify({"version": 1, "items": items}, "\t")


func save_file(file: String = "") -> bool:
	var target := file if file != "" else path
	if target == "":
		return false
	if FileAccess.file_exists(target):
		var old := FileAccess.get_file_as_string(target)
		var bak := FileAccess.open(target + ".bak", FileAccess.WRITE)
		if bak:
			bak.store_string(old)
	var f := FileAccess.open(target, FileAccess.WRITE)
	if f == null:
		push_error("MapProps: cannot write %s" % target)
		return false
	f.store_string(to_json())
	return true


func snapshot() -> String:
	return JSON.stringify(items)


func restore(snap: String) -> void:
	var parsed = JSON.parse_string(snap)
	if typeof(parsed) == TYPE_ARRAY:
		items = parsed
		rebuild_all()


func get_item(id: int) -> Dictionary:
	for it in items:
		if int(it["id"]) == id:
			return it
	return {}


func add_point(type: String, x: float, z: float, yaw: float = 0.0, s: float = 1.0) -> int:
	var it := {"id": _next_id, "type": type, "x": x, "z": z, "yaw": yaw, "s": s}
	_next_id += 1
	items.append(it)
	rebuild_item(int(it["id"]))
	return int(it["id"])


func add_line(type: String, pts: Array, w: float = -1.0, smooth: bool = false) -> int:
	var width := w if w >= 0.0 else float(TYPES[type].get("w", 0.0))
	var it := {"id": _next_id, "type": type, "pts": pts, "w": width, "smooth": smooth}
	_next_id += 1
	items.append(it)
	rebuild_item(int(it["id"]))
	return int(it["id"])


func remove_item(id: int) -> void:
	for i in range(items.size()):
		if int(items[i]["id"]) == id:
			items.remove_at(i)
			break
	if nodes.has(id):
		nodes[id].queue_free()
		nodes.erase(id)


# ------------------------------------------------------------------ building

func rebuild_all() -> void:
	for n in nodes.values():
		n.queue_free()
	nodes.clear()
	for it in items:
		_build(it)


func rebuild_item(id: int) -> void:
	if nodes.has(id):
		nodes[id].queue_free()
		nodes.erase(id)
	var it := get_item(id)
	if not it.is_empty():
		_build(it)


## Moves / rotates a point object without rebuilding its mesh.
func update_transform(id: int) -> void:
	var it := get_item(id)
	if it.is_empty() or not nodes.has(id):
		return
	var n: Node3D = nodes[id]
	if kind_of(String(it["type"])) == "point":
		n.position = Vector3(float(it["x"]), float(it.get("y", 0.0)), float(it["z"]))
		n.rotation.y = float(it["yaw"])
	else:
		n.position.y = float(it.get("y", 0.0))


func _build(it: Dictionary) -> void:
	var id := int(it["id"])
	var type := String(it["type"])
	var root := Node3D.new()
	root.name = "item_%d" % id
	root.set_meta("prop_id", id)
	add_child(root)
	nodes[id] = root
	match kind_of(type):
		"point":
			root.position = Vector3(float(it["x"]), float(it.get("y", 0.0)), float(it["z"]))
			root.rotation.y = float(it["yaw"])
			var lp := LowPoly.new()
			var col := PackedVector3Array()
			_point_mesh(type, float(it.get("s", 1.0)), lp, col)
			_attach(root, lp, col, id, true)
		"line":
			var pts: Array = it["pts"]
			root.position.y = float(it.get("y", 0.0))
			if pts.size() < 2:
				return
			var smooth := bool(it.get("smooth", false))
			if is_path(type):
				_build_path(root, it, id, sample(pts, smooth, 0.8))
			elif type == "hedge":
				_build_hedge(root, sample(pts, smooth, 0.8), id)
			elif type == "hedge_box":
				_build_hedge_box(root, sample(pts, smooth, 0.8), id)
			else:
				_build_fence(root, type, sample(pts, smooth, 3.0), id)
		"area":
			root.position.y = float(it.get("y", 0.0))
			if (it["pts"] as Array).size() >= 3:
				_build_area(root, it, id)


## `pick`: also adds a box on collision layer 2 around the mesh so the editor can click a crown or a seat from
## any side; layer 2 does not block the walker.
func _attach(node: Node3D, lp: LowPoly, col: PackedVector3Array, id: int, pick: bool = false) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = lp.build(materials)
	node.add_child(mi)
	if pick and mi.mesh.get_surface_count() > 0:
		var bb := mi.mesh.get_aabb()
		var box := BoxShape3D.new()
		box.size = bb.size + Vector3(0.1, 0.1, 0.1)
		var pcs := CollisionShape3D.new()
		pcs.shape = box
		pcs.position = bb.get_center()
		var pbody := StaticBody3D.new()
		pbody.collision_layer = 2
		pbody.collision_mask = 0
		pbody.set_meta("prop_id", id)
		pbody.add_child(pcs)
		node.add_child(pbody)
	if col.size() > 0:
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(col)
		shape.backface_collision = true
		var cs := CollisionShape3D.new()
		cs.shape = shape
		var body := StaticBody3D.new()
		body.set_meta("prop_id", id)
		body.add_child(cs)
		node.add_child(body)


# ---- point objects (local frame: origin at the base, front = +z)

static func _col_wall(col: PackedVector3Array, x0: float, z0: float, x1: float, z1: float, h: float) -> void:
	var a0 := Vector3(x0, 0.0, z0)
	var b0 := Vector3(x1, 0.0, z1)
	col.append_array([a0, b0, Vector3(x1, h, z1), a0, Vector3(x1, h, z1), Vector3(x0, h, z0)])


## A horizontal collision face (the top of a grave slab: candles stand on it).
static func _col_top(col: PackedVector3Array, x0: float, z0: float, x1: float, z1: float, y: float) -> void:
	col.append_array([Vector3(x0, y, z0), Vector3(x1, y, z0), Vector3(x1, y, z1), Vector3(x0, y, z0), Vector3(x1, y, z1), Vector3(x0, y, z1)])


static func _col_box(col: PackedVector3Array, hx: float, hz: float, h: float, cx: float = 0.0, cz: float = 0.0) -> void:
	_col_wall(col, cx - hx, cz - hz, cx + hx, cz - hz, h)
	_col_wall(col, cx + hx, cz - hz, cx + hx, cz + hz, h)
	_col_wall(col, cx + hx, cz + hz, cx - hx, cz + hz, h)
	_col_wall(col, cx - hx, cz + hz, cx - hx, cz - hz, h)


static func _col_trunk(col: PackedVector3Array, r: float, h: float) -> void:
	for i in range(8):
		var a0 := TAU * float(i) / 8.0
		var a1 := TAU * float(i + 1) / 8.0
		_col_wall(col, cos(a0) * r, sin(a0) * r, cos(a1) * r, sin(a1) * r, h)


func _point_mesh(type: String, k: float, lp: LowPoly, col: PackedVector3Array) -> void:
	var dark := Color(0.5, 0.5, 0.5)
	match type:
		"conifer":
			var h := 10.0 * k
			lp.cylinder("g_bark", Vector3.ZERO, 0.18 * k, k, 6, dark, Color(0.8, 0.8, 0.8), 1.0)
			lp.cone("g_conifer", Vector3(0, 0.5 * k, 0), 1.5 * k, h - 0.5 * k, 8, Color(0.55, 0.55, 0.55), Color.WHITE, 3.0)
			_col_trunk(col, 0.3 * k, 3.0)
		"leafy":
			var h := 9.0 * k
			lp.cylinder("g_bark", Vector3.ZERO, 0.28 * k, h * 0.45, 7, dark, Color(0.8, 0.8, 0.8), 2.0)
			lp.cone("g_foliage", Vector3(0, h * 0.30, 0), h * 0.42, h * 0.40, 10, Color(0.55, 0.55, 0.55), Color.WHITE, 3.0)
			lp.cone("g_foliage", Vector3(0, h * 0.55, 0), h * 0.32, h * 0.45, 10, Color(0.65, 0.65, 0.65), Color.WHITE, 3.0)
			_col_trunk(col, 0.4 * k, 3.0)
		"cross_wood":
			_cross_wood(lp, k)
			_col_box(col, 0.3 * k, 0.3 * k, 2.5 * k)
		"cross_iron":
			lp.box("c_stone", Vector3(0, 0.5 * k, 0), Vector3(k, k, k), 1.2)
			lp.box("c_black", Vector3(0, 2.1 * k, 0), Vector3(0.14 * k, 2.2 * k, 0.14 * k), 1.0)
			lp.box("c_black", Vector3(0, 2.575 * k, 0), Vector3(k, 0.15 * k, 0.12 * k), 1.0)
			_col_box(col, 0.5 * k, 0.5 * k, 1.2 * k)
		"shrine":
			lp.box("brick", Vector3(0, 0.5 * k, 0), Vector3(1.4 * k, k, 1.4 * k), 1.2)
			for cx in [-0.625, 0.625]:
				for cz in [-0.625, 0.625]:
					lp.box("brick", Vector3(cx * k, 1.6 * k, cz * k), Vector3(0.15 * k, 1.2 * k, 0.15 * k), 1.2)
			for o: Vector3 in [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
				var right := Vector3(o.z, 0, -o.x)
				var c := o * 0.66 * k + Vector3(0, 1.6 * k, 0)
				lp.quad_out("win", c - right * 0.4 * k - Vector3(0, 0.5 * k, 0), c + right * 0.4 * k - Vector3(0, 0.5 * k, 0),
					c + right * 0.4 * k + Vector3(0, 0.5 * k, 0), c - right * 0.4 * k + Vector3(0, 0.5 * k, 0),
					Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Color.WHITE, Color.WHITE, o)
			var apex := Vector3(0, 3.3 * k, 0)
			var y0 := 2.2 * k
			var e := 1.0 * k
			var cs := [Vector3(-e, y0, -e), Vector3(e, y0, -e), Vector3(e, y0, e), Vector3(-e, y0, e)]
			var outs := [Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)]
			for i in range(4):
				lp.tri_out("c_roof", cs[i], cs[(i + 1) % 4], apex, Vector2(0, 1), Vector2(1, 1), Vector2(0.5, 0),
					Color(0.86, 0.86, 0.86), Color(0.86, 0.86, 0.86), Color.WHITE, (Vector3.UP * 1.2 + outs[i]).normalized())
			_col_box(col, 0.7 * k, 0.7 * k, 2.2 * k)
		"bench":
			lp.box("g_wood", Vector3(0, 0.45 * k, 0), Vector3(1.7 * k, 0.06 * k, 0.5 * k), 1.0)
			lp.box("g_wood", Vector3(0, 0.725 * k, -0.22 * k), Vector3(1.7 * k, 0.35 * k, 0.06 * k), 1.0)
			for sx in [-0.75, 0.75]:
				lp.box("g_wood", Vector3(sx * k, 0.21 * k, 0), Vector3(0.08 * k, 0.42 * k, 0.08 * k), 1.0)
			_col_box(col, 0.85 * k, 0.25 * k, 0.9 * k)
		"bench_plain":
			lp.box("g_wood", Vector3(0, 0.455 * k, 0), Vector3(1.8 * k, 0.07 * k, 0.4 * k), 1.0)
			for sx in [-0.68, 0.68]:
				lp.box("p_concrete", Vector3(sx * k, 0.21 * k, 0), Vector3(0.14 * k, 0.42 * k, 0.38 * k), 1.0)
			_col_box(col, 0.9 * k, 0.2 * k, 0.5 * k)
		"bush_round":
			_blob(lp, "p_box_hedge", Vector3(0, 0.55 * k, 0), Vector3(0.65, 0.6, 0.65) * k, 8, 5, 7, 0.1, 0.0)
			_col_trunk(col, 0.5 * k, 1.0 * k)
		"tree_ball":
			lp.cylinder("g_bark", Vector3.ZERO, 0.05 * k, 1.35 * k, 5, Color(0.5, 0.5, 0.5), Color(0.8, 0.8, 0.8), 1.0)
			_blob(lp, "p_box_hedge", Vector3(0, 1.7 * k, 0), Vector3(0.5, 0.47, 0.5) * k, 8, 5, 11, 0.1, -INF)
			_col_trunk(col, 0.1 * k, 1.5 * k)
		"boulder":
			_boulder(lp, k)
			_col_box(col, 0.75 * k, 0.5 * k, 0.8 * k)
		"grave", "grave_double":
			var gw := 2.0 if type == "grave_double" else 1.0
			_grave(lp, k, gw)
			_col_box(col, gw * 0.5 * k, 1.0 * k, 0.45 * k)
			# tops: the slab over the head end, the kerb level over the gravel at the foot
			_col_top(col, -gw * 0.5 * k, -0.88 * k, gw * 0.5 * k, 0.38 * k, 0.29 * k)
			_col_top(col, -gw * 0.5 * k, 0.38 * k, gw * 0.5 * k, 1.0 * k, 0.22 * k)
		"candle":
			_candle(lp, Vector3.ZERO, k)
		"candles":
			for c: Array in [[0.0, 0.0, 1.0], [0.17, 0.06, 0.85], [-0.13, 0.12, 1.15], [0.05, -0.16, 0.9], [-0.18, -0.1, 0.8]]:
				_candle(lp, Vector3(float(c[0]) * k, 0.0, float(c[1]) * k), k * float(c[2]))
		"bin":
			lp.cylinder("p_metal", Vector3.ZERO, 0.24 * k, 0.76 * k, 8, Color(0.55, 0.55, 0.55), Color.WHITE, 0.5)
			lp.cylinder("p_metal", Vector3(0, 0.74 * k, 0), 0.265 * k, 0.07 * k, 8, Color(0.8, 0.8, 0.8), Color.WHITE, 0.5)
			lp.cylinder("c_black", Vector3(0, 0.75 * k, 0), 0.215 * k, 0.065 * k, 8)
			_col_trunk(col, 0.27 * k, 0.8 * k)
		"notice_board":
			for sx in [-0.7, 0.7]:
				lp.box("p_metal", Vector3(sx * k, 1.0 * k, 0), Vector3(0.07 * k, 2.0 * k, 0.07 * k), 1.0)
			lp.box("p_metal", Vector3(0, 1.38 * k, 0), Vector3(1.5 * k, 1.05 * k, 0.06 * k), 1.0)
			var bf := Vector3(0, 1.38 * k, 0.032 * k)
			var bw := Vector3(0.72 * k, 0, 0)
			var bh := Vector3(0, 0.5 * k, 0)
			lp.quad_out("p_notice", bf - bw - bh, bf + bw - bh, bf + bw + bh, bf - bw + bh,
				Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), Color(0.9, 0.9, 0.9), Color.WHITE, Vector3(0, 0, 1))
			lp.box("p_metal", Vector3(0, 1.935 * k, 0.03 * k), Vector3(1.64 * k, 0.05 * k, 0.24 * k), 1.0)
			_col_box(col, 0.78 * k, 0.1 * k, 2.0 * k)


static func _hash01(i: int, j: int, seed: int) -> float:
	return fposmod(sin(float(i) * 12.9898 + float(j) * 78.233 + float(seed) * 37.719) * 43758.5453, 1.0)


## A lumpy ellipsoid (bushes, the boulder): `rings` x `seg` vertices, each pushed in / out by up to `jitter`
## (deterministic from `seed`). Vertices below `floor_y` are clamped to it (a flat bottom on the ground);
## `front_z` (if finite) cuts the +z side flat (the face of the monument stone).
static func _blob(lp: LowPoly, key: String, c: Vector3, r: Vector3, seg: int, rings: int, seed: int, jitter: float,
		floor_y: float, front_z: float = INF, uv_scale: float = 1.0) -> void:
	var grid: Array = []
	for j in range(rings + 1):
		var lat := -PI * 0.5 + PI * float(j) / rings
		var row: Array = []
		for i in range(seg):
			var lon := TAU * float(i) / seg
			var f := 1.0 + jitter * (_hash01(0 if (j == 0 or j == rings) else i, j, seed) - 0.5) * 2.0
			var d := Vector3(cos(lat) * cos(lon), sin(lat), cos(lat) * sin(lon))
			var p := c + Vector3(d.x * r.x, d.y * r.y, d.z * r.z) * f
			p.y = maxf(p.y, floor_y)
			p.z = minf(p.z, front_z)
			row.append(p)
		grid.append(row)
	var bot := Color(0.55, 0.55, 0.55)
	var top := Color.WHITE
	var h := maxf(r.y * 2.0, 0.01)
	for j in range(rings):
		for i in range(seg):
			var i2 := (i + 1) % seg
			var q: Array = [grid[j][i], grid[j][i2], grid[j + 1][i2], grid[j + 1][i]]
			var uvs: Array = []
			var cols: Array = []
			var ns: Array = []
			for k in range(4):
				var p: Vector3 = q[k]
				var ii := i if (k == 0 or k == 3) else i + 1
				var jj := j if k < 2 else j + 1
				uvs.append(Vector2(float(ii) / seg * TAU * maxf(r.x, r.z) / uv_scale, float(jj) / rings * PI * r.y / uv_scale))
				cols.append(bot.lerp(top, clampf((p.y - (c.y - r.y)) / h, 0.0, 1.0)))
				var nn := (p - c) / Vector3(r.x * r.x, r.y * r.y, r.z * r.z)
				ns.append(Vector3(0, 0, 1) if p.z >= front_z - 0.001 else nn.normalized())
			if (q[0] as Vector3).distance_to(q[1]) > 0.0005:
				lp.tri(key, q[0], q[1], q[2], uvs[0], uvs[1], uvs[2], cols[0], cols[1], cols[2], ns[0], ns[1], ns[2])
			if (q[2] as Vector3).distance_to(q[3]) > 0.0005:
				lp.tri(key, q[0], q[2], q[3], uvs[0], uvs[2], uvs[3], cols[0], cols[2], cols[3], ns[0], ns[2], ns[3])


## The roadside cross of the church yard (photo: tall square post, a beam two thirds up, a glory of pointed
## wooden rays behind the crossing, a small cap on the top, a saw-tooth carving down the lower post).
static func _cross_wood(lp: LowPoly, k: float) -> void:
	var h := 5.6 * k
	var pw := 0.34 * k
	lp.box("g_darkwood", Vector3(0, h * 0.5, 0), Vector3(pw, h, pw), 1.0)
	var yc := h * 0.74
	lp.box("g_darkwood", Vector3(0, yc, 0.04 * k), Vector3(2.2 * k, 0.3 * k, 0.3 * k), 1.0)
	lp.box("g_darkwood", Vector3(0, h + 0.05 * k, 0), Vector3(0.44 * k, 0.1 * k, 0.44 * k), 1.0)
	lp.box("g_darkwood", Vector3(0, h + 0.13 * k, 0), Vector3(0.3 * k, 0.06 * k, 0.3 * k), 1.0)
	# the glory: separate pointed rays, long and short in turn, in a plane through the post
	var n := 20
	var c := Color(0.9, 0.9, 0.9)
	for i in range(n):
		var a := TAU * (float(i) + 0.5) / n
		var d := Vector2(cos(a), sin(a))
		var side := Vector2(-d.y, d.x)
		var length := (1.08 if i % 2 == 0 else 0.72) * k
		var base := d * 0.22 * k
		var hw := 0.09 * k
		var p0 := Vector3(base.x + side.x * hw, yc + base.y + side.y * hw, -0.02 * k)
		var p1 := Vector3(base.x - side.x * hw, yc + base.y - side.y * hw, -0.02 * k)
		var tip := Vector3(d.x * length, yc + d.y * length, -0.02 * k)
		for sg in [1.0, -1.0]:
			lp.tri_out("g_raywood", p0, p1, tip, Vector2(0, 0), Vector2(0.15, 0), Vector2(0.075, 1.0), c, c, Color.WHITE,
				Vector3(0, 0, float(sg)))
	# saw-tooth carving on both edges of the lower post, front and back
	var y := 0.9 * k
	while y < 3.3 * k:
		for sx in [1.0, -1.0]:
			var x := float(sx) * pw * 0.5
			for sz in [1.0, -1.0]:
				var z := float(sz) * (pw * 0.5 + 0.002)
				lp.tri_out("g_darkwood", Vector3(x, y, z), Vector3(x, y + 0.16 * k, z), Vector3(x + float(sx) * 0.07 * k, y + 0.16 * k, z),
					Vector2(0, 0), Vector2(0, 0.2), Vector2(0.1, 0.2), c, c, c, Vector3(0, 0, float(sz)))
		y += 0.2 * k


## A field boulder used as a monument: lumpy, pinkish granite, a flat front face with a dark granite plaque.
static func _boulder(lp: LowPoly, k: float) -> void:
	var fz := 0.46 * k
	_blob(lp, "p_boulder", Vector3(0, 0.36 * k, 0), Vector3(0.85, 0.55, 0.62) * k, 9, 5, 23, 0.2, 0.0, fz, 1.0)
	var c := Vector3(0, 0.42 * k, fz + 0.012 * k)
	var w := Vector3(0.24 * k, 0, 0)
	var hh := Vector3(0, 0.15 * k, 0)
	lp.quad_out("p_granite", c - w - hh, c + w - hh, c + w + hh, c - w + hh, Vector2(0, 1), Vector2(0.5, 1), Vector2(0.5, 0.65), Vector2(0, 0.65),
		Color.WHITE, Color.WHITE, Vector3(0, 0, 1))
	for i in range(3):
		var ly := 0.5 * k - float(i) * 0.075 * k
		var lw := (0.16 - 0.03 * float(i)) * k
		lp.quad_out("p_gold", Vector3(-lw, ly - 0.012 * k, c.z + 0.003), Vector3(lw, ly - 0.012 * k, c.z + 0.003),
			Vector3(lw, ly + 0.012 * k, c.z + 0.003), Vector3(-lw, ly + 0.012 * k, c.z + 0.003),
			Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Color.WHITE, Color.WHITE, Vector3(0, 0, 1))


## A Polish grave: granite kerb frame, a slab over the head end, gravel at the foot, a headstone with a small
## cross and gold lettering. Front (+z) = the foot end where people stand. `w` = 1 (single) or 2 (double).
static func _grave(lp: LowPoly, k: float, w: float) -> void:
	var hw := w * 0.5 * k
	var hl := 1.0 * k
	var fh := 0.22 * k
	var gc := Color(0.62, 0.62, 0.64)
	for sx in [-1.0, 1.0]:
		lp.box("p_granite", Vector3(float(sx) * (hw - 0.06 * k), fh * 0.5, 0), Vector3(0.12 * k, fh, hl * 2.0), 1.0, gc)
	for sz in [-1.0, 1.0]:
		lp.box("p_granite", Vector3(0, fh * 0.5, float(sz) * (hl - 0.06 * k)), Vector3(hw * 2.0 - 0.24 * k, fh, 0.12 * k), 1.0, gc)
	var z0 := -hl + 0.12 * k
	var z1 := hl - 0.62 * k
	lp.box("p_granite", Vector3(0, fh + 0.02 * k, (z0 + z1) * 0.5), Vector3(hw * 2.0 - 0.16 * k, 0.1 * k, z1 - z0), 1.0, gc)
	var gy := fh * 0.75
	lp.quad_out("dirt", Vector3(-hw + 0.12 * k, gy, z1), Vector3(hw - 0.12 * k, gy, z1), Vector3(hw - 0.12 * k, gy, hl - 0.12 * k),
		Vector3(-hw + 0.12 * k, gy, hl - 0.12 * k), Vector2(0, 0), Vector2(hw, 0), Vector2(hw, 0.25), Vector2(0, 0.25),
		Color(0.8, 0.8, 0.8), Color(0.8, 0.8, 0.8), Vector3.UP)
	# headstone at the head end (-z)
	var sw := minf(0.9 * k, hw * 2.0 - 0.1 * k) if w < 1.5 else 1.5 * k
	var sh := 0.9 * k
	var sz0 := -hl + 0.12 * k
	lp.box("p_granite", Vector3(0, fh + sh * 0.5, sz0), Vector3(sw, sh, 0.14 * k), 1.0, gc)
	lp.box("p_granite", Vector3(0, fh + sh + 0.18 * k, sz0), Vector3(0.06 * k, 0.36 * k, 0.06 * k), 1.0)
	lp.box("p_granite", Vector3(0, fh + sh + 0.25 * k, sz0), Vector3(0.22 * k, 0.06 * k, 0.06 * k), 1.0)
	var fz := sz0 + 0.072 * k
	var cols := 2 if w > 1.5 else 1
	for ci in range(cols):
		var cx := 0.0 if cols == 1 else (float(ci) - 0.5) * sw * 0.5
		for li in range(4):
			var ly := fh + sh * (0.78 - 0.13 * float(li))
			var lw := (0.26 - 0.05 * float(li % 2)) * k
			lp.quad_out("p_gold", Vector3(cx - lw * 0.5, ly - 0.018 * k, fz), Vector3(cx + lw * 0.5, ly - 0.018 * k, fz),
				Vector3(cx + lw * 0.5, ly + 0.018 * k, fz), Vector3(cx - lw * 0.5, ly + 0.018 * k, fz),
				Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Color.WHITE, Color.WHITE, Vector3(0, 0, 1))
	# a vase for flowers on the slab
	lp.cylinder("p_granite", Vector3(hw * 0.45, fh + 0.07 * k, sz0 + 0.3 * k), 0.06 * k, 0.22 * k, 6)


## A grave candle (znicz): red glass (glows at dusk and at night), a gold metal lid.
static func _candle(lp: LowPoly, at: Vector3, k: float) -> void:
	lp.cylinder("p_candle", at, 0.06 * k, 0.15 * k, 6, Color(0.8, 0.8, 0.8), Color.WHITE, 0.15 * k)
	lp.cylinder("p_gold", at + Vector3(0, 0.15 * k, 0), 0.066 * k, 0.04 * k, 6, Color.WHITE, Color.WHITE, 0.2)


# ---- polylines

func _build_path(root: Node3D, it: Dictionary, id: int, pts: Array) -> void:
	var paving := paving_of(String(it["type"]))
	var spec: Array = PAVING.get(paving, PAVING["cobble"])
	var key := String(spec[0])
	var tile := float(spec[1])
	var width := maxf(float(it.get("w", 2.0)), 0.3)
	var y := pave_y(paving)
	var n := pts.size()
	var hw := width * 0.5
	var left: Array[Vector3] = []
	var right: Array[Vector3] = []
	var dists: Array[float] = [0.0]
	for i in range(n):
		var p := Vector2(pts[i][0], pts[i][1])
		var d_in := Vector2.ZERO
		var d_out := Vector2.ZERO
		if i > 0:
			d_in = (p - Vector2(pts[i - 1][0], pts[i - 1][1])).normalized()
		if i < n - 1:
			d_out = (Vector2(pts[i + 1][0], pts[i + 1][1]) - p).normalized()
		if i > 0:
			dists.append(dists[i - 1] + p.distance_to(Vector2(pts[i - 1][0], pts[i - 1][1])))
		var n_in := Vector2(-d_in.y, d_in.x) if d_in != Vector2.ZERO else Vector2.ZERO
		var n_out := Vector2(-d_out.y, d_out.x) if d_out != Vector2.ZERO else Vector2.ZERO
		var nn := (n_in + n_out)
		nn = nn.normalized() if nn.length() > 0.001 else (n_in if n_in != Vector2.ZERO else n_out)
		var ref := n_out if n_out != Vector2.ZERO else n_in
		var miter := clampf(1.0 / maxf(nn.dot(ref), 0.35), 1.0, 2.2)
		left.append(Vector3(p.x + nn.x * hw * miter, y, p.y + nn.y * hw * miter))
		right.append(Vector3(p.x - nn.x * hw * miter, y, p.y - nn.y * hw * miter))
	var lp := LowPoly.new()
	for i in range(n - 1):
		lp.quad_out(key, right[i], left[i], left[i + 1], right[i + 1],
			_wuv(right[i], tile), _wuv(left[i], tile), _wuv(left[i + 1], tile), _wuv(right[i + 1], tile),
			PAVE_COLOR, PAVE_COLOR, Vector3.UP)
	_attach(root, lp, PackedVector3Array(), id)


## Texture coordinates from the world position: neighbouring pieces of the same paving continue the pattern.
static func _wuv(p: Vector3, tile: float) -> Vector2:
	return Vector2(p.x / tile, p.z / tile)


## A paved polygon (plac): the outline is triangulated; one material, world UVs, the same height as paths of
## that paving, so a square and the paths running into it merge into one surface.
func _build_area(root: Node3D, it: Dictionary, id: int) -> void:
	var paving := paving_of(String(it["type"]))
	var spec: Array = PAVING.get(paving, PAVING["cobble"])
	var key := String(spec[0])
	var tile := float(spec[1])
	var y := pave_y(paving)
	var outline := area_outline(it)
	var poly := PackedVector2Array()
	for p in outline:
		poly.append(Vector2(p[0], p[1]))
	var idx := Geometry2D.triangulate_polygon(poly)
	if idx.is_empty():
		# a self-crossing outline cannot be triangulated: pave its convex hull instead of showing nothing
		poly = Geometry2D.convex_hull(poly)
		idx = Geometry2D.triangulate_polygon(poly)
	var lp := LowPoly.new()
	for i in range(0, idx.size(), 3):
		var a := Vector3(poly[idx[i]].x, y, poly[idx[i]].y)
		var b := Vector3(poly[idx[i + 1]].x, y, poly[idx[i + 1]].y)
		var c := Vector3(poly[idx[i + 2]].x, y, poly[idx[i + 2]].y)
		lp.tri(key, a, b, c, _wuv(a, tile), _wuv(b, tile), _wuv(c, tile), PAVE_COLOR, PAVE_COLOR, PAVE_COLOR,
			Vector3.UP, Vector3.UP, Vector3.UP)
	_attach(root, lp, PackedVector3Array(), id)


func _build_hedge(root: Node3D, pts: Array, id: int) -> void:
	var lp := LowPoly.new()
	for i in range(pts.size() - 1):
		var a := Vector2(pts[i][0], pts[i][1])
		var b := Vector2(pts[i + 1][0], pts[i + 1][1])
		var length := a.distance_to(b)
		var steps := maxi(int(ceil(length / 1.4)), 1)
		for j in range(steps + (1 if i == pts.size() - 2 else 0)):
			var p := a.lerp(b, float(j) / steps)
			lp.cone("g_conifer", Vector3(p.x, 0.0, p.y), 0.8, 2.6, 7, Color(0.55, 0.55, 0.55), Color.WHITE, 2.0)
	_attach(root, lp, PackedVector3Array(), id)


## A clipped hedge (privet / box): a continuous block 0.7 m wide and 1.0 m high following the line, mitred at
## the bends, with collision.
func _build_hedge_box(root: Node3D, pts: Array, id: int) -> void:
	var hw := 0.35
	var h := 1.0
	var n := pts.size()
	var left: Array[Vector2] = []
	var right: Array[Vector2] = []
	for i in range(n):
		var p := Vector2(pts[i][0], pts[i][1])
		var d_in := (p - Vector2(pts[i - 1][0], pts[i - 1][1])).normalized() if i > 0 else Vector2.ZERO
		var d_out := (Vector2(pts[i + 1][0], pts[i + 1][1]) - p).normalized() if i < n - 1 else Vector2.ZERO
		var n_in := Vector2(-d_in.y, d_in.x)
		var n_out := Vector2(-d_out.y, d_out.x)
		var nn := n_in + n_out
		nn = nn.normalized() if nn.length() > 0.001 else (n_in if d_in != Vector2.ZERO else n_out)
		var ref := n_out if d_out != Vector2.ZERO else n_in
		var miter := clampf(1.0 / maxf(nn.dot(ref), 0.35), 1.0, 2.2)
		left.append(p + nn * hw * miter)
		right.append(p - nn * hw * miter)
	var lp := LowPoly.new()
	var col := PackedVector3Array()
	var dark := Color(0.5, 0.5, 0.5)
	var dist := 0.0
	for i in range(n - 1):
		var seg := Vector2(pts[i][0], pts[i][1]).distance_to(Vector2(pts[i + 1][0], pts[i + 1][1]))
		var u0 := dist
		var u1 := dist + seg
		dist = u1
		for side in [[left, 1.0], [right, -1.0]]:
			var e: Array[Vector2] = side[0]
			var a := e[i]
			var b := e[i + 1]
			var mid := (Vector2(pts[i][0], pts[i][1]) + Vector2(pts[i + 1][0], pts[i + 1][1])) * 0.5
			var o2 := ((a + b) * 0.5 - mid).normalized()
			var out_n := Vector3(o2.x, 0.0, o2.y)
			lp.quad_out("p_box_hedge", Vector3(a.x, 0.0, a.y), Vector3(b.x, 0.0, b.y), Vector3(b.x, h, b.y), Vector3(a.x, h, a.y),
				Vector2(u0, h), Vector2(u1, h), Vector2(u1, 0), Vector2(u0, 0), dark, Color.WHITE, out_n)
		lp.quad_out("p_box_hedge", Vector3(right[i].x, h, right[i].y), Vector3(left[i].x, h, left[i].y),
			Vector3(left[i + 1].x, h, left[i + 1].y), Vector3(right[i + 1].x, h, right[i + 1].y),
			Vector2(0, u0), Vector2(0.7, u0), Vector2(0.7, u1), Vector2(0, u1), Color(1.1, 1.1, 1.0), Color(1.1, 1.1, 1.0), Vector3.UP)
		_col_wall(col, pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1], h)
	for end in [[0, 1.0], [n - 1, -1.0]]:
		var k: int = end[0]
		var a := left[k]
		var b := right[k]
		var p := Vector2(pts[k][0], pts[k][1])
		var q := Vector2(pts[k + int(end[1])][0], pts[k + int(end[1])][1])
		var o := (p - q).normalized()
		lp.quad_out("p_box_hedge", Vector3(a.x, 0.0, a.y), Vector3(b.x, 0.0, b.y), Vector3(b.x, h, b.y), Vector3(a.x, h, a.y),
			Vector2(0, h), Vector2(0.7, h), Vector2(0.7, 0), Vector2(0, 0), dark, Color.WHITE, Vector3(o.x, 0.0, o.y))
	_attach(root, lp, col, id)


func _build_fence(root: Node3D, type: String, pts: Array, id: int) -> void:
	var stone := type != "fence_brick"
	var base_key := "c_stone" if stone else "brick"
	var is_wall := type == "wall_stone"
	var n := pts.size()
	for i in range(n - 1):
		var a := Vector2(pts[i][0], pts[i][1])
		var b := Vector2(pts[i + 1][0], pts[i + 1][1])
		var length := a.distance_to(b)
		if length < 0.3:
			continue
		var d := (b - a) / length
		var seg := Node3D.new()
		seg.position = Vector3(a.x, 0.0, a.y)
		seg.rotation.y = atan2(-d.y, d.x)       # local +x runs along the segment
		root.add_child(seg)
		var lp := LowPoly.new()
		var col := PackedVector3Array()
		var posts := maxi(int(round(length / POST_SPACING)), 1)
		var h := 1.1 if is_wall else FENCE_H
		for j in range(posts + 1):
			if j == posts and i < n - 2:
				continue                               # the next segment draws this joint
			var x := length * float(j) / posts
			lp.box(base_key, Vector3(x, 0.875, 0), Vector3(0.48, 1.75, 0.48), 1.2)
			lp.box("c_stone", Vector3(x, 1.825, 0), Vector3(0.64, 0.15, 0.64), 1.2)
		for j in range(posts):
			var x0 := length * float(j) / posts + 0.3
			var x1 := length * float(j + 1) / posts - 0.3
			if is_wall:
				lp.box("c_stone", Vector3((x0 + x1) * 0.5, 0.55, 0), Vector3(x1 - x0, 1.1, 0.4), 1.2)
				continue
			lp.box(base_key, Vector3((x0 + x1) * 0.5, BASE_H * 0.5, 0), Vector3(x1 - x0, BASE_H, 0.24), 1.2)
			var span := x1 - x0
			for sg in [1.0, -1.0]:
				var z := 0.02 * float(sg)
				lp.quad_out("g_picket", Vector3(x0, BASE_H, z), Vector3(x1, BASE_H, z), Vector3(x1, FENCE_H, z), Vector3(x0, FENCE_H, z),
					Vector2(0, 1), Vector2(span, 1), Vector2(span, 0), Vector2(0, 0), Color(0.85, 0.85, 0.85), Color.WHITE,
					Vector3(0, 0, float(sg)))
		_col_wall(col, 0.0, 0.0, length, 0.0, h)
		_attach(seg, lp, col, id)
