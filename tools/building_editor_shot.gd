extends SceneTree

## Screenshot of the building tab of the map editor: one house selected and changed, one hidden, one added.
## Then the windows-and-doors mode on a house next to it: brick facade, a wide door, a shop window and a row of
## windows put in by hand (outlines of the editor visible). Nothing is saved.
## Output: docs/look/building_editor.png, docs/look/building_openings.png, building_openings_auto.png
const ViewScript = preload("res://src/world/linia_view.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	var world = view.world
	var bs: BuildingSet = world.buildings
	var sp: Vector3 = world.spawn_position
	# the three houses nearest the spawn point
	var near: Array = []
	for id in bs.order:
		var c := BuildingKit.centroid(bs.ring_of(id))
		near.append([c.distance_to(Vector2(sp.x, sp.z)), id, c])
	near.sort_custom(func(a, b): return a[0] < b[0])
	view.toggle_editor()
	var ed: MapEditor = view.editor
	ed.set_mode("buildings")
	var bed: BuildingEditor = ed.bed
	bed.select(int(near[1][1]))
	bed.remove_selected()
	bed.select(int(near[0][1]))
	bed.set_arch("kostka")
	var c0: Vector2 = near[0][2]
	view.set_camera(Vector3(c0.x + 22.0, 14.0, c0.y + 22.0), Vector3(c0.x, 2.0, c0.y))
	world.debug_fog_off = true
	world.set_phase("day")
	for i in range(6):
		await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	print("shot err=", img.save_png(ProjectSettings.globalize_path("res://docs/look/building_editor.png")))

	# windows and doors on the third nearest house: the longest wall, seen from the front
	var hid := int(near[2][1])
	bed.select(hid)
	bed.set_arch("dom_parterowy")
	var walls: Array = bs.info(hid)["walls"]
	var we := 0
	for k in range(walls.size()):
		if float(walls[k]["len"]) > float(walls[we]["len"]):
			we = k
	var wa: Vector2 = walls[we]["a"]
	var wb: Vector2 = walls[we]["b"]
	var wn: Vector2 = walls[we]["n"]
	var mid := (wa + wb) * 0.5
	var eye := mid + wn * 11.0
	var cam_eye := Vector3(eye.x, 2.2, eye.y)
	var cam_at := Vector3(mid.x, 1.6, mid.y)
	view.set_camera(cam_eye, cam_at)
	for i in range(4):
		await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://docs/look/building_openings_auto.png"))
	bed.set_op_mode(true)
	var length := float(walls[we]["len"])
	var own := bed._own_openings()
	own.clear()
	own.append({"e": we, "t": 0.5, "y": 0.0, "w": 1.6, "h": 2.3, "k": "door"})
	own.append({"e": we, "t": 0.5 - 2.4 / length, "y": 0.5, "w": 2.2, "h": 1.8, "k": "shop"})
	for k in range(2):
		own.append({"e": we, "t": 0.5 + (1.8 + k * 1.5) / length, "y": 1.2, "w": 0.9, "h": 1.1, "k": "win_lit" if k == 1 else "win"})
	bs.set_ov(hid, "facade", "brick")
	bs.rebuild_lifted()
	bed.op_sel = 0
	bed.op_kind = ""
	ed._update_status()
	for i in range(4):
		await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://docs/look/building_openings.png"))
	print("openings shots done")
	quit()
