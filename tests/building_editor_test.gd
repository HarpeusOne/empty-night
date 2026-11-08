extends SceneTree

## Building editor logic (no mouse): pick a house, change its type / storeys / ridge / footprint, move and rotate it
## (with collision following it), hide and restore an OSM building, add / copy / delete new ones, undo, save + load.
## Works on a clean state and a test file; data/blockout/overrides.json is not touched.
const ViewScript = preload("res://src/world/linia_view.gd")
const TEST_PATH := "res://data/blockout/test_overrides.json"
var fails := 0

func check(ok: bool, msg: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + msg)
	if not ok:
		fails += 1

func _initialize() -> void:
	call_deferred("_run")

func _frames(n: int = 2) -> void:
	for i in range(n):
		await physics_frame

## Horizontal ray from `from` along `dir`: distance to the first building wall (INF = none).
func _wall_dist(bs: BuildingSet, from: Vector3, dir: Vector3) -> float:
	var q := PhysicsRayQueryParameters3D.create(from, from + dir * 40.0)
	var hit := bs.get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return INF
	return from.distance_to(hit["position"])

func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	var world = view.world
	var bs: BuildingSet = world.buildings
	bs.path = TEST_PATH
	bs.restore(JSON.stringify({"version": 1, "buildings": {}, "added": []}))
	check(bs.footprints.size() == bs.order.size(), "clean state: %d houses, all visible" % bs.order.size())
	var used: Dictionary = {}
	for id in bs.order:
		used[bs.arch_id(id)] = true
	check(used.size() >= 6, "default archetypes are varied (%d types in use)" % used.size())

	view.toggle_editor()
	var ed: MapEditor = view.editor
	ed.set_mode("buildings")
	var bed: BuildingEditor = ed.bed
	check(ed.mode == "buildings" and bed != null, "F3 tab: buildings")

	# a near-rectangular single-storey house, far enough from others to test its walls
	var hid := -1
	for id in bs.order:
		var ring := bs.ring_of(id)
		if int(bs.entries[id]["levels"]) == 1 and BuildingKit.fill_ratio(ring) > 0.95 and absf(BuildingKit.signed_area(ring)) > 70.0:
			var c := BuildingKit.centroid(ring)
			if world.point_in_footprint(c + Vector2(9, 0)) == -1 and world.point_in_footprint(c + Vector2(16, 0)) == -1:
				hid = id
				break
	check(hid != -1, "found a test house (%d)" % hid)
	await _frames()
	var c0 := BuildingKit.centroid(bs.ring_of(hid))
	check(bs.pick(Vector3(c0.x, 40.0, c0.y), Vector3.DOWN) == hid, "a ray from above picks the house (roof)")
	var side := (Vector3(c0.x + 15.0, 1.5, c0.y) - Vector3(c0.x, 1.5, c0.y))
	check(bs.pick(Vector3(c0.x + 15.0, 1.5, c0.y), Vector3.LEFT) == hid, "a ray from the side picks it (wall)")

	bed.select(hid)
	check(bs.lifted == hid and bs.footprints.size() == bs.order.size(), "selecting lifts it out, it stays a footprint")
	bed.set_arch("kostka")
	check(bs.arch_id(hid) == "kostka" and absf(float(bs.info(hid)["wall_h"]) - 5.6) < 0.01, "type -> kostka: 2 storeys, walls 5.6 m")
	bed.change_storeys(1)
	check(bs.storeys_of(hid) == 3 and absf(float(bs.info(hid)["wall_h"]) - 8.4) < 0.01, "PgUp: 3 storeys, walls 8.4 m")
	bed.set_arch("dom_poddasze")
	check(bs.storeys_of(hid) == 1 and float(bs.info(hid)["top"]) > 6.0, "type -> house with attic: ridge above 6 m (%.1f)" % float(bs.info(hid)["top"]))
	var ridge_a: Vector2 = bs.info(hid)["ridge_dir"]
	bed.toggle_ridge()
	var ridge_b: Vector2 = bs.info(hid)["ridge_dir"]
	check(absf(ridge_a.dot(ridge_b)) < 0.01, "V turns the ridge by 90 degrees")
	bed.toggle_ridge()

	# move: the collision moves with it
	await _frames()
	var probe := Vector3(c0.x + 15.0, 1.0, c0.y)
	var d_before := _wall_dist(bs, probe, Vector3.LEFT)
	bs.set_ov(hid, "dx", 5.0)
	bs.rebuild_lifted()
	await _frames()
	var d_after := _wall_dist(bs, probe, Vector3.LEFT)
	check(absf((d_before - d_after) - 5.0) < 0.3, "moved 5 m east: its wall is 5 m closer (%.2f -> %.2f)" % [d_before, d_after])
	check(world.point_in_footprint(c0 + Vector2(5, 0)) == hid, "footprint moved too")
	bs.set_ov(hid, "dx", null)
	bs.rebuild_lifted()
	var r0 := bs.ring_of(hid)
	bed.rotate_selected(90.0)
	var r1 := bs.ring_of(hid)
	check(BuildingKit.centroid(r1).distance_to(BuildingKit.centroid(r0)) < 0.01 and r1[0].distance_to(r0[0]) > 1.0, "rotate 90 about its centre")
	ed.undo()
	check(bs.ring_of(hid)[0].distance_to(r0[0]) < 0.01, "undo the rotation")
	bed.scale_selected(1.05)
	check(absf(float(bs.get_ov(hid, "scale")) - 1.05) < 0.001, "] makes it bigger")

	# hide / restore
	bed.remove_selected()
	await _frames()
	check(bs.is_hidden(hid) and world.point_in_footprint(c0) == -1 and bs.hidden_at(c0) == hid, "X hides an OSM house (still clickable)")
	check(_wall_dist(bs, probe, Vector3.LEFT) > d_before + 3.0, "a hidden house has no walls")
	bed.remove_selected()
	check(not bs.is_hidden(hid) and world.point_in_footprint(c0) == hid, "X again brings it back")

	# windows, doors and the wall finish
	bed.set_arch("dom_parterowy")
	var auto: Array = bed.openings_of(hid)
	var auto_doors := auto.filter(func(o): return String(o["k"]) == "door").size()
	check(auto.size() >= 2 and auto_doors == 1 and not bed.has_own_openings(hid), "automatic layout: %d openings, one door" % auto.size())
	bed.next_facade()
	check(String(bs.get_ov(hid, "facade")) == "wall2", "E: wall finish -> grey plaster")
	for k in range(BuildingKit.FACADES.size() - 1):
		bed.next_facade()
	check(bs.get_ov(hid, "facade") == null, "E round the list: back to the type's own finish")
	bed.set_op_mode(true)
	check(bed.op_mode, "O: windows and doors mode")
	var walls: Array = bs.info(hid)["walls"]
	var we := -1
	for k in range(walls.size()):
		if float(walls[k]["len"]) > 6.0:
			we = k
			break
	var wa: Vector2 = walls[we]["a"]
	var wb: Vector2 = walls[we]["b"]
	var wn: Vector2 = walls[we]["n"]
	var spot := wa + (wb - wa) * 0.2 + wn * 12.0
	var aim := wa + (wb - wa) * 0.2
	var ray_o := Vector3(spot.x, 1.5, spot.y)
	var hit := bed.wall_hit(ray_o, (Vector3(aim.x, 1.5, aim.y) - ray_o).normalized())
	check(not hit.is_empty() and int(hit["e"]) == we and absf(float(hit["s"]) / float(hit["len"]) - 0.2) < 0.01 and absf(float(hit["y"]) - 1.5) < 0.01,
		"a ray at the wall finds wall %d at 20 %% and 1.5 m" % we)
	ed._push_undo()
	var di := bed.add_opening("door", hit)
	var own: Array = bed.openings_of(hid)
	check(bed.has_own_openings(hid) and own.size() == auto.size() + 1, "a new door: the automatic layout became the house's own list + 1")
	check(float(own[di]["y"]) == 0.0 and String(own[di]["k"]) == "door", "a door stands on the ground")
	check(bed.opening_at(hit) == di, "clicking it again selects it")
	var w0 := float(own[di]["w"])
	bed.resize_opening(0.2, 0.0)
	check(absf(float(bed.openings_of(hid)[di]["w"]) - w0 - 0.2) < 0.001, "] makes it wider")
	bed.set_opening_kind("win")
	check(String(bed.openings_of(hid)[di]["k"]) == "win" and float(bed.openings_of(hid)[di]["y"]) > 0.5, "kind -> window: lifted off the ground")
	bed.copy_opening()
	check(bed.openings_of(hid).size() == auto.size() + 2 and bed.op_sel == auto.size() + 1, "C copies it next to it")
	bed.delete_opening()
	check(bed.openings_of(hid).size() == auto.size() + 1, "X deletes the copy")
	ed.undo()
	check(bed.openings_of(hid).size() == auto.size() + 2, "undo brings the copy back")
	bed.reset_openings()
	check(not bed.has_own_openings(hid) and bed.openings_of(hid).size() == auto.size(), "Home: back to the automatic layout")
	ed._push_undo()
	bed.add_opening("garage", hit)
	bs.set_ov(hid, "facade", "brick")
	bs.rebuild_lifted()
	bed.set_op_mode(false)
	check(not bed.op_mode, "O again leaves the mode")

	# an irregular footprint -> rectangle
	var irr := -1
	for id in bs.order:
		if BuildingKit.fill_ratio(bs.ring_of(id)) < 0.8 and String(bs.entries[id]["kind"]) == "house":
			irr = id
			break
	if irr != -1:
		bed.select(irr)
		bed.set_arch("dom_parterowy")
		var was := bool(bs.info(irr)["irregular"])
		bed.toggle_rect()
		check(was and not bool(bs.info(irr)["irregular"]) and bs.ring_of(irr).size() == 4, "B: irregular footprint -> rectangle with a sloped roof")

	# new building, copy, delete
	bed.select(-1)
	check(bs.lifted == -1, "Esc / deselect merges it back")
	var nid := bed.place("garaz", Vector2(620.0, 620.0))
	await _frames()
	check(nid < 0 and bs.pick(Vector3(620, 30, 620), Vector3.DOWN) == nid, "place a new garage and pick it")
	bed.duplicate_selected()
	var cid := bed.sel
	check(cid != nid and bs.arch_id(cid) == "garaz" and bs.is_added(cid), "C copies it")
	bed.remove_selected()
	check(not bs.entries.has(cid), "X deletes an added building")

	# save / load
	check(bs.save_file(TEST_PATH), "save")
	var snap := bs.snapshot()
	var bs2 := BuildingSet.new()
	bs2.materials = world.materials
	root.add_child(bs2)
	bs2.setup(world.data["buildings"], [], TEST_PATH)
	check(bs2.snapshot() == snap, "load gives the same state")
	check(bs2.arch_id(hid) == "dom_parterowy" and bs2.entries.has(nid), "including types and added buildings")
	check(String(bs2.get_ov(hid, "facade")) == "brick" and (bs2.get_ov(hid, "openings") as Array).size() == auto.size() + 1,
		"including the wall finish and the house's own openings")
	bs2.queue_free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH + ".bak"))

	ed.set_mode("props")
	check(ed.mode == "props" and bs.lifted == -1, "back to the props tab")
	view.toggle_editor()
	print("=== RESULT: %d failed ===" % fails)
	quit(1 if fails > 0 else 0)
