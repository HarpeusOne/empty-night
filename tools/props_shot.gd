extends SceneTree

## The map props on an empty field outside the village (nothing is saved): all objects in a row, close-ups, and
## the paving test (a square, a red stripe and an overlapping grey path that should read as one surface).
## Needs a window. Output: docs/look/props_*.png
const ViewScript = preload("res://src/world/linia_view.gd")
const X0 := 700.0
const Z0 := 900.0

func _initialize() -> void:
	call_deferred("_run")

func _shot(view, name: String, eye: Vector3, target: Vector3) -> void:
	view.set_camera(eye, target)
	for i in range(4):
		await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("res://docs/look/props_%s.png" % name))
	print("shot ", name)

func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	view.show_help(false)
	var world = view.world
	var props: MapProps = world.props
	var row := ["conifer", "leafy", "bush_round", "tree_ball", "cross_wood", "cross_iron", "shrine", "boulder", "grave",
		"grave_double", "candles", "bench", "bench_plain", "bin", "notice_board"]
	var x := X0
	for t in row:
		props.add_point(t, x, Z0)
		x += 3.2
	props.add_line("hedge", [[X0, Z0 + 6.0], [X0 + 14.0, Z0 + 6.0]])
	props.add_line("hedge_box", [[X0 + 18.0, Z0 + 6.0], [X0 + 30.0, Z0 + 6.0], [X0 + 34.0, Z0 + 2.5]])
	# paving: a trapezoid square of grey cobble, a grey path running into it, a red stripe across both,
	# a graphite square next to it and a gravel area
	var px := X0 + 60.0
	props.add_line("area_cobble", [[px, Z0], [px + 16.0, Z0], [px + 12.0, Z0 - 10.0], [px + 3.0, Z0 - 10.0]])
	props.add_line("path_cobble", [[px - 12.0, Z0 + 4.0], [px + 4.0, Z0 - 3.0], [px + 9.0, Z0 - 5.0]], 3.0)
	props.add_line("path_cobble_red", [[px - 2.0, Z0 - 1.0], [px + 18.0, Z0 - 1.0]], 0.6)
	props.add_line("area_cobble_grey", [[px + 16.5, Z0 + 0.5], [px + 24.0, Z0 + 0.5], [px + 24.0, Z0 - 8.0], [px + 13.5, Z0 - 8.0]])
	props.add_line("area_gravel", [[px - 6.0, Z0 + 3.0], [px - 1.0, Z0 + 8.0], [px + 5.0, Z0 + 6.0], [px + 2.0, Z0 + 1.0]], -1.0, true)
	# a grave with candles on it for the dusk shot
	var gx := X0 + 30.0
	props.add_point("grave", gx, Z0 + 14.0)
	var cid := props.add_point("candles", gx, Z0 + 14.6)
	props.get_item(cid)["y"] = 0.33
	props.update_transform(cid)
	props.add_point("grave_double", gx + 2.5, Z0 + 14.0)
	props.add_point("candle", gx + 2.3, Z0 + 14.8)
	for i in range(4):
		await process_frame
	world.debug_fog_off = true
	world.set_phase("day")
	await _shot(view, "row", Vector3(X0 + 22.0, 9.0, Z0 + 26.0), Vector3(X0 + 22.0, 1.0, Z0))
	await _shot(view, "cross", Vector3(X0 + 12.8 + 3.0, 1.7, Z0 + 5.5), Vector3(X0 + 12.8, 3.8, Z0))
	await _shot(view, "graves", Vector3(X0 + 26.0, 2.2, Z0 + 4.5), Vector3(X0 + 29.0, 0.5, Z0))
	await _shot(view, "street", Vector3(X0 + 39.0, 1.7, Z0 + 5.0), Vector3(X0 + 41.6, 0.8, Z0))
	await _shot(view, "boulder", Vector3(X0 + 22.4 + 1.5, 1.4, Z0 + 3.2), Vector3(X0 + 22.4, 0.4, Z0))
	await _shot(view, "paving", Vector3(px + 6.0, 22.0, Z0 + 16.0), Vector3(px + 6.0, 0.0, Z0 - 2.0))
	await _shot(view, "paving_low", Vector3(px - 8.0, 1.7, Z0 + 8.0), Vector3(px + 8.0, 0.0, Z0 - 4.0))
	world.debug_fog_off = false
	world.set_phase("night")
	await _shot(view, "candles_night", Vector3(gx + 1.2, 1.6, Z0 + 18.0), Vector3(gx + 1.2, 0.3, Z0 + 14.0))
	quit()
