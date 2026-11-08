class_name BuildingSet
extends Node3D

## All houses of the map (OSM footprints from data/blockout/centrum.json, without the church) plus the author's
## changes from the building editor, saved in data/blockout/overrides.json:
##   {"version": 1,
##    "buildings": {"<osm id>": {"arch", "storeys", "dx", "dz", "yaw", "scale", "rect", "ridge", "tint", "hidden"}},
##    "added": [{"id": -1000, "ring": [[x, z], ...], <same keys>}]}
## Every key is optional; a missing building keeps its default archetype (chosen from OSM size and storeys).
##
## Rendering: all buildings are merged into one mesh and one collision body (few draw calls). The building being
## edited is "lifted" out into its own node, so moving / rotating it rebuilds one house, not 360.

const ARCH_PATH := "res://data/buildings/archetypes.json"
const OVERRIDES_PATH := "res://data/blockout/overrides.json"
const OV_KEYS := ["arch", "storeys", "dx", "dz", "yaw", "scale", "rect", "ridge", "tint", "hidden", "facade", "openings"]

signal rebuilt

var materials: Dictionary = {}
var road_pts: Array = []           # Vector2 (x, z) of every road vertex (doors face the nearest one)
var archetypes: Dictionary = {}
var arch_order: Array = []
var entries: Dictionary = {}        # id -> {id, kind, levels, height, base: PackedVector2Array, added: bool}
var order: Array = []               # ids in build order
var ov: Dictionary = {}             # id -> override dictionary (OV_KEYS)
var lifted := -1
var path := OVERRIDES_PATH
var footprints: Array = []          # visible buildings: [{id, ring, height, top, kind, irregular}]
var stats: Dictionary = {}
var build_ms := 0

var _info: Dictionary = {}          # id -> {ring, wall_h, top, irregular, roof}
var _merged: MeshInstance3D
var _merged_body: StaticBody3D
var _lift: MeshInstance3D
var _lift_body: StaticBody3D
const FIRST_ADDED_ID := -1000   # -1 means "none" (selection, lifted), so added ids start far below it
var _next_added := FIRST_ADDED_ID


func setup(buildings: Array, p_road_pts: Array, file: String = OVERRIDES_PATH) -> void:
	path = file
	road_pts = p_road_pts
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(ARCH_PATH))
	archetypes = parsed["types"]
	arch_order = parsed["order"]
	for b in buildings:
		if String(b["kind"]) == "church":
			continue
		var ring := PackedVector2Array()
		for p in b["ring"]:
			ring.append(Vector2(p[0], -p[1]))
		var id := int(b["id"])
		entries[id] = {"id": id, "kind": String(b["kind"]), "levels": int(b["levels"]), "height": float(b["height"]),
			"base": ring, "added": false}
		order.append(id)
	_load_overrides()
	build_all()


# ------------------------------------------------------------------ data

func _load_overrides() -> void:
	if not FileAccess.file_exists(path):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("BuildingSet: cannot read %s" % path)
		return
	_apply_state(parsed)


func _apply_state(state: Dictionary) -> void:
	# drop the previous added buildings and overrides, then apply `state`
	for id in order.duplicate():
		if bool(entries[id]["added"]):
			entries.erase(id)
			order.erase(id)
	ov.clear()
	_next_added = FIRST_ADDED_ID
	var bl: Dictionary = state.get("buildings", {})
	for key in bl:
		var id := int(key)
		if entries.has(id):
			ov[id] = _norm((bl[key] as Dictionary).duplicate(true))
	for a in state.get("added", []):
		var id := int(a["id"])
		var ring := PackedVector2Array()
		for p in a["ring"]:
			ring.append(Vector2(p[0], p[1]))
		entries[id] = {"id": id, "kind": "house", "levels": 1, "height": 3.0, "base": ring, "added": true}
		order.append(id)
		var o := {}
		for k in OV_KEYS:
			if (a as Dictionary).has(k):
				o[k] = a[k]
		ov[id] = _norm(o.duplicate(true))
		_next_added = mini(_next_added, id - 1)


## JSON reads every number as a float: whole-number fields go back to int, so a loaded state equals the saved one.
static func _norm(o: Dictionary) -> Dictionary:
	for k in ["storeys", "tint"]:
		if o.has(k):
			o[k] = int(o[k])
	if o.get("openings") is Array:
		for op in o["openings"]:
			op["e"] = int(op["e"])
	return o


func get_state() -> Dictionary:
	var bl := {}
	var added: Array = []
	for id in order:
		var o: Dictionary = ov.get(id, {})
		if bool(entries[id]["added"]):
			var a := {"id": id, "ring": []}
			for p in entries[id]["base"]:
				a["ring"].append([snappedf(p.x, 0.01), snappedf(p.y, 0.01)])
			a.merge(o)
			added.append(a)
		elif not o.is_empty():
			bl[str(id)] = o
	return {"version": 1, "buildings": bl, "added": added}


func snapshot() -> String:
	return JSON.stringify(get_state())


func restore(snap: String) -> void:
	if snap == snapshot():
		return
	_apply_state(JSON.parse_string(snap))
	if lifted != -1 and not entries.has(lifted):
		lifted = -1
	build_all()


func save_file(file: String = "") -> bool:
	var target := path if file == "" else file
	if FileAccess.file_exists(target):
		DirAccess.copy_absolute(ProjectSettings.globalize_path(target), ProjectSettings.globalize_path(target + ".bak"))
	var f := FileAccess.open(target, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(get_state(), "  ", false))
	f.close()
	return true


func get_ov(id: int, key: String, default: Variant = null) -> Variant:
	return (ov.get(id, {}) as Dictionary).get(key, default)


func set_ov(id: int, key: String, value: Variant) -> void:
	if not ov.has(id):
		ov[id] = {}
	if value == null:
		(ov[id] as Dictionary).erase(key)
	else:
		ov[id][key] = value


func is_hidden(id: int) -> bool:
	return bool(get_ov(id, "hidden", false))


func is_added(id: int) -> bool:
	return entries.has(id) and bool(entries[id]["added"])


## Default archetype from the OSM data: public buildings keep their height, small sheds become garages,
## 2 storeys a PRL cube, 3+ a block; single-storey houses get a stable mix of the common village types.
func default_arch(id: int) -> String:
	var e: Dictionary = entries[id]
	var kind := String(e["kind"])
	if kind != "house":
		return "publiczny"
	var area := absf(BuildingKit.signed_area(e["base"]))
	var levels := int(e["levels"])
	if area < 30.0:
		return "garaz"
	if levels >= 3:
		return "blok"
	if levels == 2:
		return "kostka"
	var h := absi(id * 2654435761) % 20
	if area < 55.0 and h % 2 == 0:
		return "obora"
	if h < 9:
		return "dom_poddasze"
	if h < 15:
		return "dom_parterowy"
	if h < 18:
		return "dom_nowy"
	return "dom_ceglany"


func arch_id(id: int) -> String:
	var a := String(get_ov(id, "arch", ""))
	return a if archetypes.has(a) else default_arch(id)


func storeys_of(id: int) -> int:
	var arch: Dictionary = archetypes[arch_id(id)]
	return int(get_ov(id, "storeys", int(arch["storeys"])))


## The footprint after the author's changes: rectangle, scale and rotation about the centre, then the shift.
func ring_of(id: int) -> PackedVector2Array:
	var base: PackedVector2Array = entries[id]["base"]
	if bool(get_ov(id, "rect", false)):
		base = BuildingKit.rect_ring(base)
	var c := BuildingKit.centroid(base)
	var s := float(get_ov(id, "scale", 1.0))
	var yaw := float(get_ov(id, "yaw", 0.0))
	var shift := Vector2(float(get_ov(id, "dx", 0.0)), float(get_ov(id, "dz", 0.0)))
	var out := PackedVector2Array()
	for p in base:
		out.append(((p - c) * s).rotated(-yaw) + c + shift)
	return out


func info(id: int) -> Dictionary:
	return _info.get(id, {})


# ------------------------------------------------------------------ editing

func add_building(arch: String, centre: Vector2, w: float = 10.0, d: float = 8.0, yaw: float = 0.0) -> int:
	var id := _next_added
	_next_added -= 1
	var ring := PackedVector2Array()
	for c in [Vector2(-w, -d), Vector2(w, -d), Vector2(w, d), Vector2(-w, d)]:
		ring.append((c * 0.5).rotated(-yaw) + centre)
	entries[id] = {"id": id, "kind": "house", "levels": 1, "height": 3.0, "base": ring, "added": true}
	order.append(id)
	ov[id] = {"arch": arch}
	return id


## A new added building with the same footprint (shifted by `offset`) and the same settings.
func duplicate_building(id: int, offset: Vector2) -> int:
	var ring := ring_of(id)
	var nid := _next_added
	_next_added -= 1
	var moved := PackedVector2Array()
	for p in ring:
		moved.append(p + offset)
	entries[nid] = {"id": nid, "kind": "house", "levels": 1, "height": 3.0, "base": moved, "added": true}
	order.append(nid)
	var o := {}
	for k in ["storeys", "ridge", "tint", "facade", "openings"]:
		if get_ov(id, k) != null:
			o[k] = (get_ov(id, k) as Array).duplicate(true) if get_ov(id, k) is Array else get_ov(id, k)
	o["arch"] = arch_id(id)
	ov[nid] = o
	return nid


## OSM buildings are only hidden (X again brings them back); added ones are deleted.
func remove_building(id: int) -> void:
	if not entries.has(id):
		return
	if is_added(id):
		entries.erase(id)
		order.erase(id)
		ov.erase(id)
		if lifted == id:
			lifted = -1
	else:
		set_ov(id, "hidden", null if is_hidden(id) else true)


func reset_building(id: int) -> void:
	if is_added(id):
		for k in ["dx", "dz", "yaw", "scale", "rect", "ridge", "storeys", "tint", "facade", "openings"]:
			set_ov(id, k, null)
	else:
		ov.erase(id)


# ------------------------------------------------------------------ building the meshes

func _road_point(c: Vector2) -> Vector2:
	var best := c
	var best_d := INF
	for rp in road_pts:
		var dsq := c.distance_squared_to(rp)
		if dsq < best_d:
			best_d = dsq
			best = rp
	return best


func _gen(kit: BuildingKit, id: int) -> void:
	var ring := ring_of(id)
	if ring.size() < 3:
		return
	var e: Dictionary = entries[id]
	var arch: Dictionary = archetypes[arch_id(id)]
	var res := kit.building(ring, arch, {"id": id, "storeys": storeys_of(id), "data_height": float(e["height"]),
		"road": _road_point(BuildingKit.centroid(ring)), "ridge_flip": bool(get_ov(id, "ridge", false)),
		"tint": int(get_ov(id, "tint", -1)), "facade": String(get_ov(id, "facade", "")), "openings": get_ov(id, "openings")})
	res["ring"] = ring
	_info[id] = res


func _body(faces: PackedVector3Array, body_name: String) -> StaticBody3D:
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.backface_collision = true     # a wall must block from both sides, whatever its winding
	var cs := CollisionShape3D.new()
	cs.shape = shape
	var body := StaticBody3D.new()
	body.name = body_name
	body.add_child(cs)
	return body


## Rebuilds every building (about 0.1 s): on load, on selecting / releasing a building, after undo.
func build_all() -> void:
	var t0 := Time.get_ticks_msec()
	for n in [_merged, _merged_body, _lift, _lift_body]:
		if n != null:
			n.queue_free()
			remove_child(n)
	_merged = null
	_merged_body = null
	_lift = null
	_lift_body = null
	_info.clear()
	var lp := LowPoly.new()
	var faces := PackedVector3Array()
	var kit := BuildingKit.new(lp, faces)
	for id in order:
		if id == lifted or is_hidden(id):
			continue
		_gen(kit, id)
	stats = kit.stats
	_merged = MeshInstance3D.new()
	_merged.name = "Buildings"
	_merged.mesh = lp.build(materials)
	add_child(_merged)
	_merged_body = _body(faces, "BuildingsBody")
	add_child(_merged_body)
	if lifted != -1:
		rebuild_lifted()
	else:
		_refresh_footprints()
	build_ms = Time.get_ticks_msec() - t0


## Rebuilds only the lifted (edited) building.
func rebuild_lifted() -> void:
	for n in [_lift, _lift_body]:
		if n != null:
			n.queue_free()
			remove_child(n)
	_lift = null
	_lift_body = null
	if lifted == -1 or not entries.has(lifted):
		_refresh_footprints()
		return
	_info.erase(lifted)
	if not is_hidden(lifted):
		var lp := LowPoly.new()
		var faces := PackedVector3Array()
		_gen(BuildingKit.new(lp, faces), lifted)
		_lift = MeshInstance3D.new()
		_lift.name = "EditedBuilding"
		_lift.mesh = lp.build(materials)
		add_child(_lift)
		_lift_body = _body(faces, "EditedBuildingBody")
		add_child(_lift_body)
	_refresh_footprints()


func lift(id: int) -> void:
	if id == lifted:
		return
	lifted = id
	build_all()


func drop() -> void:
	if lifted == -1:
		return
	lifted = -1
	build_all()


func _refresh_footprints() -> void:
	footprints.clear()
	for id in order:
		if not _info.has(id):
			continue
		var i: Dictionary = _info[id]
		footprints.append({"id": id, "ring": i["ring"], "height": float(i["wall_h"]), "top": float(i["top"]),
			"kind": String(entries[id]["kind"]), "irregular": bool(i["irregular"])})
	rebuilt.emit()


# ------------------------------------------------------------------ queries

func point_in_footprint(p: Vector2) -> int:
	for f in footprints:
		if Geometry2D.is_point_in_polygon(p, f["ring"]):
			return int(f["id"])
	return -1


## Hidden buildings are still selectable by clicking the ground inside their old outline.
func hidden_at(p: Vector2) -> int:
	for id in order:
		if is_hidden(id) and Geometry2D.is_point_in_polygon(p, ring_of(id)):
			return id
	return -1


## The building hit by a ray: the nearest wall (physics) or roof (the plane at the top of the walls, a box up to
## the ridge is close enough for clicking). -1 = none.
func pick(origin: Vector3, dir: Vector3) -> int:
	var best := -1
	var best_t := INF
	var space := get_world_3d().direct_space_state
	var exclude: Array[RID] = []
	for _i in range(8):
		var q := PhysicsRayQueryParameters3D.create(origin, origin + dir * 400.0)
		q.exclude = exclude
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			break
		var col: Object = hit["collider"]
		if col == _merged_body or col == _lift_body:
			var pos: Vector3 = hit["position"]
			for probe in [pos + dir * 0.05, pos - dir * 0.05, pos + Vector3(hit["normal"]) * -0.05]:
				var id := point_in_footprint(Vector2(probe.x, probe.z))
				if id != -1:
					best = id
					best_t = origin.distance_to(pos)
					break
			break
		if (hit["position"] as Vector3).y < 0.02:
			break     # the ground
		exclude.append(hit["rid"])
	if absf(dir.y) > 0.0001:
		for f in footprints:
			var t := (float(f["height"]) - origin.y) / dir.y
			if t <= 0.0 or t >= best_t:
				continue
			var p := origin + dir * t
			if Geometry2D.is_point_in_polygon(Vector2(p.x, p.z), f["ring"]):
				best = int(f["id"])
				best_t = t
	return best
