extends SceneTree

## Screenshot of curved paths / fence made with the map editor API (not saved). Output: docs/look/editor_curves.png
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
	var props: MapProps = world.props
	var ox := 300.0
	var oz := 300.0
	var pts := [[ox, oz], [ox + 10, oz - 6], [ox + 22, oz - 4], [ox + 32, oz + 6], [ox + 44, oz + 8]]
	props.add_line("path_cobble", pts.duplicate(true), 3.0, true)
	props.add_line("path_asphalt", [[ox, oz + 14], [ox + 12, oz + 10], [ox + 26, oz + 16], [ox + 40, oz + 28]], 4.0, true)
	props.add_line("fence_stone", [[ox, oz - 14], [ox + 14, oz - 18], [ox + 28, oz - 12], [ox + 42, oz - 16]], 0.0, true)
	props.add_line("path_cobble", [[ox, oz + 30], [ox + 14, oz + 30], [ox + 28, oz + 34]], 3.0, false)
	view.set_camera(Vector3(ox + 20, 40.0, oz + 40.0), Vector3(ox + 22, 0.0, oz + 6.0))
	world.debug_fog_off = true
	world.set_phase("day")
	for i in range(6):
		await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	print("shot err=", img.save_png(ProjectSettings.globalize_path("res://docs/look/editor_curves.png")))
	quit()
