extends SceneTree

## Map props + editor logic (no mouse needed): build, add / pick / rotate / scale / duplicate / delete / undo,
## drawing a path, inserting a point, save + load round trip, fence picking, editor on / off.
const ViewScript = preload("res://src/world/linia_view.gd")
var fails := 0

func check(ok: bool, msg: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + msg)
	if not ok:
		fails += 1

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	var world = view.world
	var props: MapProps = world.props
	check(props.items.size() >= 20, "default yard layout loaded (%d items)" % props.items.size())
	check(props.nodes.size() == props.items.size(), "every item has a node")
	var fence_id := -1
	for it in props.items:
		if String(it["type"]) == "fence_brick":
			fence_id = int(it["id"])
			break
	check(fence_id > 0 and props.nodes[fence_id].find_children("*", "StaticBody3D", true, false).size() > 0, "a fence has collision")

	view.toggle_editor()
	var ed: MapEditor = view.editor
	check(ed.active and bool(world.walker.fly) and bool(world.walker.editor_mode), "editor on: flying, mouse not captured by clicks")
	for i in range(2):
		await physics_frame

	var n0 := props.items.size()
	var id := ed.place_point("bench", Vector2(300.0, 300.0))
	check(props.items.size() == n0 + 1 and props.nodes.has(id) and ed.sel == id, "place a bench and select it")
	for i in range(2):
		await physics_frame
	check(ed.pick_ray(Vector3(300, 20, 300), Vector3.DOWN) == id, "a ray from above picks the bench")
	check(ed.pick_ray(Vector3(310, 20, 300), Vector3.DOWN) != id, "a ray beside it does not")

	ed.rotate_selected(15.0)
	check(absf(float(props.get_item(id)["yaw"]) - deg_to_rad(15.0)) < 0.001 and absf(props.nodes[id].rotation.y - deg_to_rad(15.0)) < 0.001, "rotate 15 degrees (data and node)")
	ed.scale_selected(1.15)
	check(absf(float(props.get_item(id)["s"]) - 1.15) < 0.001 and props.nodes.has(id), "scale up")
	ed.move_selected_y(0.5)
	check(absf(float(props.get_item(id)["y"]) - 0.5) < 0.001 and absf(props.nodes[id].position.y - 0.5) < 0.001, "raise by 0.5 m (data and node)")
	ed.move_selected_y(-0.1)
	check(absf(props.nodes[id].position.y - 0.4) < 0.001, "lower by 0.1 m")
	for i in range(2):
		await physics_frame
	check(ed.pick_ray(Vector3(300, 20, 300), Vector3.DOWN) == id, "a raised bench is still picked")
	ed.duplicate_selected()
	check(absf(float(props.get_item(ed.sel).get("y", 0.0)) - 0.4) < 0.001, "duplicate keeps the height")
	ed.undo()
	ed.select(id)
	ed.duplicate_selected()
	check(props.items.size() == n0 + 2, "duplicate")
	ed.delete_selected()
	check(props.items.size() == n0 + 1, "delete the copy")
	ed.undo()
	check(props.items.size() == n0 + 2, "undo restores it")

	# draw a path
	ed.arm("path_gravel")
	for p in [Vector2(320, 300), Vector2(340, 300), Vector2(340, 320)]:
		ed.add_draft_point(p)
	var pid := ed.finish_draft()
	check(pid > 0 and (props.get_item(pid)["pts"] as Array).size() == 3, "draw a 3-point gravel path")
	check(ed.pick_ray(Vector3(330, 20, 300), Vector3.DOWN) == pid, "a ray from above picks the path by its footprint")
	ed.insert_point_at(Vector2(330, 301))
	check((props.get_item(pid)["pts"] as Array).size() == 4, "insert a point")
	ed.delete_selected()
	check((props.get_item(pid)["pts"] as Array).size() == 3, "delete the inserted point only")
	ed.scale_selected(2.0)
	check(absf(float(props.get_item(pid)["w"]) - 5.0) < 0.001, "path widens with ]")
	ed.move_selected_y(1.0)
	check(absf(props.nodes[pid].position.y - 1.0) < 0.001, "a polyline can be raised")
	ed.reset_selected_y()
	check(absf(props.nodes[pid].position.y) < 0.001, "Home puts it back on the ground")
	ed.rotate_selected(90.0)
	check(props.nodes.has(pid), "rotate a polyline")

	# curves
	ed.arm("")
	ed.select(pid)
	check(MapProps.sample(props.get_item(pid)["pts"], false, 0.8).size() == 3, "a straight line is not resampled")
	ed.toggle_smooth()
	var smp := MapProps.sample(props.get_item(pid)["pts"], true, 0.8)
	check(bool(props.get_item(pid)["smooth"]) and smp.size() > 10, "smooth: the curve has %d sample points" % smp.size())
	check(Vector2(smp[0][0], smp[0][1]).is_equal_approx(Vector2(props.get_item(pid)["pts"][0][0], props.get_item(pid)["pts"][0][1])) and
		Vector2(smp[-1][0], smp[-1][1]).is_equal_approx(Vector2(props.get_item(pid)["pts"][2][0], props.get_item(pid)["pts"][2][1])), "the curve passes through the end points")
	var mid_c: Array = smp[smp.size() / 2]
	check(ed.pick_ray(Vector3(mid_c[0], 20, mid_c[1]), Vector3.DOWN) == pid, "a ray over the curve picks the path")
	ed.arm("path_asphalt")
	ed.draft_smooth = true
	for p3 in [Vector2(360, 300), Vector2(380, 310), Vector2(400, 300), Vector2(420, 310)]:
		ed.add_draft_point(p3)
	var aid := ed.finish_draft()
	check(aid > 0 and bool(props.get_item(aid)["smooth"]) and String(props.get_item(aid)["type"]) == "path_asphalt", "draw a curved asphalt path")
	ed.arm("fence_stone")
	for p4 in [Vector2(440, 300), Vector2(460, 320), Vector2(480, 300)]:
		ed.add_draft_point(p4)
	var fid := ed.finish_draft()
	check(fid > 0 and props.nodes[fid].get_child_count() >= 2, "a curved fence is built from several segments")
	check(bool(props.get_item(fid)["smooth"]), "the fence was drawn smooth (draft_smooth carried over)")
	ed.arm("")
	ed.select(fid)
	ed.toggle_smooth()
	check(not bool(props.get_item(fid)["smooth"]), "K switches a line back to straight")
	ed.draft_smooth = false
	ed.arm("")

	# fence picking from the side
	var f := props.get_item(fence_id)
	var a := Vector2(f["pts"][0][0], f["pts"][0][1])
	var b := Vector2(f["pts"][1][0], f["pts"][1][1])
	var mid := (a + b) * 0.5
	var nrm := (b - a).normalized().orthogonal()
	var o := Vector3(mid.x + nrm.x * 4.0, 1.0, mid.y + nrm.y * 4.0)
	var d := Vector3(-nrm.x, 0.0, -nrm.y)
	check(ed.pick_ray(o, d) == fence_id, "a horizontal ray picks the fence")

	# overlapping objects: a bench under a tree crown and on a path is still picked; Tab cycles to the others
	var tree := ed.place_point("leafy", Vector2(400.0, 400.0))
	var bench2 := ed.place_point("bench", Vector2(401.5, 400.0))
	ed.arm("path_cobble")
	ed.add_draft_point(Vector2(395.0, 400.0))
	ed.add_draft_point(Vector2(410.0, 400.0))
	var path2 := ed.finish_draft()
	ed.arm("")
	for i in range(2):
		await physics_frame
	var ray_o := Vector3(401.5, 30.0, 400.0)
	var cands := ed.pick_candidates(ray_o, Vector3.DOWN)
	check(ed.pick_ray(ray_o, Vector3.DOWN) == bench2, "bench under a crown and on a path wins (got %s)" % str(cands))
	check(cands.has(tree) and cands.has(path2), "the crown and the path are the next candidates")
	ed.select(bench2)
	ed.select(tree)       # previously selected tree: clicking the bench must still give the bench
	check(ed.pick_ray(ray_o, Vector3.DOWN) == bench2, "a previously selected crown does not steal the click")
	check(ed.pick_ray(Vector3(408.0, 30.0, 400.0), Vector3.DOWN) == path2, "the bare path is picked by its footprint")

	# every type builds a mesh (new props of 2026-11-08 included)
	var bad: Array = []
	var x := 500.0
	for t in MapProps.TYPES:
		var tid: int
		match MapProps.kind_of(t):
			"point": tid = props.add_point(t, x, 500.0)
			"line": tid = props.add_line(t, [[x, 505.0], [x + 2.0, 509.0], [x + 4.0, 509.5]])
			_: tid = props.add_line(t, [[x, 515.0], [x + 3.0, 515.0], [x + 2.0, 518.0]])
		var meshes: Array = props.nodes[tid].find_children("*", "MeshInstance3D", true, false)
		var ok := meshes.size() > 0
		for m in meshes:
			ok = ok and (m as MeshInstance3D).mesh != null and (m as MeshInstance3D).mesh.get_surface_count() > 0
		if not ok:
			bad.append(t)
		x += 6.0
	check(bad.is_empty(), "all %d types build a mesh %s" % [MapProps.TYPES.size(), str(bad)])

	# paving areas (plac): drawn corner by corner, Enter closes; same paving = same height as paths, red on top
	ed.arm("area_cobble")
	ed.add_draft_point(Vector2(600.0, 600.0))
	ed.add_draft_point(Vector2(610.0, 600.0))
	check(ed.finish_draft() == -1, "an area needs 3 corners")
	ed.arm("area_cobble")
	for p in [Vector2(600, 600), Vector2(616, 600), Vector2(612, 590), Vector2(603, 590)]:
		ed.add_draft_point(p)
	var area := ed.finish_draft()
	ed.arm("path_cobble")
	ed.add_draft_point(Vector2(590.0, 604.0))
	ed.add_draft_point(Vector2(606.0, 596.0))
	var apath := ed.finish_draft()
	ed.arm("path_cobble_red")
	ed.add_draft_point(Vector2(598.0, 595.0))
	ed.add_draft_point(Vector2(618.0, 595.0))
	var red := ed.finish_draft()
	ed.arm("")
	check(area > 0 and MapProps.is_area(String(props.get_item(area)["type"])), "a trapezoid square is drawn")
	var am: Mesh = (props.nodes[area].find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D).mesh
	var tri_area := 0.0
	var ay := 0.0
	var arr: Array = am.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	for i in range(0, verts.size(), 3):
		tri_area += absf((verts[i + 1] - verts[i]).cross(verts[i + 2] - verts[i]).y) * 0.5
		ay = verts[i].y
	check(absf(tri_area - 125.0) < 0.5, "its triangles cover the trapezoid exactly (%.1f of 125 m²)" % tri_area)
	var pm: Mesh = (props.nodes[apath].find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D).mesh
	var py: float = (pm.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array)[0].y
	var rm: Mesh = (props.nodes[red].find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D).mesh
	var ry: float = (rm.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array)[0].y
	check(absf(ay - py) < 0.0001, "the grey path lies at the same height as the grey square (one surface)")
	check(ry > ay + 0.004, "the red stripe lies above the grey cobble")
	var auv: PackedVector2Array = arr[Mesh.ARRAY_TEX_UV]
	check(auv[0].distance_to(Vector2(verts[0].x, verts[0].z)) < 0.001, "paving texture is in world coordinates (patterns line up)")
	check(ed.pick_ray(Vector3(608.0, 30.0, 592.0), Vector3.DOWN) == area, "a click inside the square picks it")
	check(ed.pick_ray(Vector3(598.0, 30.0, 600.0), Vector3.DOWN) == apath, "a path lying on the square wins over the square")
	ed.select(area)
	ed.scale_selected(2.0)
	var big := MapEditor._poly_area(props.get_item(area)["pts"])
	check(absf(absf(big) - 500.0) < 2.0, "] scales the square about its centre (%.0f m²)" % absf(big))
	ed.undo()
	ed.select(area)
	ed.insert_point_at(Vector2(601.0, 595.0))
	check((props.get_item(area)["pts"] as Array).size() == 5 and ed.sel_pt == 4, "I inserts a corner on the closing side")

	# a candle placed on a grave stands on its slab, not in the ground
	var grave := ed.place_point("grave", Vector2(640.0, 640.0))
	for i in range(2):
		await physics_frame
	var cand := ed.place_point("candle", Vector2(640.0, 639.6))
	check(absf(float(props.get_item(cand)["y"]) - 0.29) < 0.02, "a candle sits on the grave slab (y %.2f)" % float(props.get_item(cand)["y"]))
	var cand2 := ed.place_point("candles", Vector2(650.0, 650.0))
	check(absf(float(props.get_item(cand2).get("y", 0.0))) < 0.001, "on bare ground it stays at 0")
	check(grave > 0, "grave placed")

	# save / load round trip
	var tmp := "res://data/map/test_props.json"
	check(props.save_file(tmp), "save")
	var p2 := MapProps.new()
	p2.materials = props.materials
	root.add_child(p2)
	p2.load_or_default(tmp, [])
	check(p2.items.size() == props.items.size() and p2.nodes.size() == props.items.size(), "load gives the same %d items" % props.items.size())
	DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp + ".bak"))

	view.toggle_editor()
	check(not ed.active and not bool(world.walker.editor_mode), "editor off")
	print("=== RESULT: %d failed ===" % fails)
	quit(1 if fails > 0 else 0)
