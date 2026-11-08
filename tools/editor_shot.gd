extends SceneTree

## Screenshot of the map editor UI with a selected polyline and a half-drawn path. Output: docs/look/editor.png
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
	var model := ChurchModel.new(null, world.church_center_en, world.CHURCH_HEADING_DEG)
	view.set_camera(model.pt(44.0, -20.0, 22.0), model.pt(20.0, -4.0, 0.0))
	view.toggle_editor()
	var ed: MapEditor = view.editor
	for it in world.props.items:
		if String(it["type"]) == "fence_brick":
			ed.select(int(it["id"]), 1)
			break
	ed.arm("path_gravel")
	var c := model.pt(36.0, 14.0, 0.0)
	ed.add_draft_point(Vector2(c.x, c.z))
	var c2 := model.pt(40.0, 24.0, 0.0)
	ed.add_draft_point(Vector2(c2.x, c2.z))
	world.debug_fog_off = true
	world.set_phase("day")
	for i in range(6):
		await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	print("shot err=", img.save_png(ProjectSettings.globalize_path("res://docs/look/editor.png")))
	quit()
