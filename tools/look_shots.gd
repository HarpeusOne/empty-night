extends SceneTree

## Screenshots of the look gate in day / dusk / night, taken from the real engine at the window size
## (so the post effect is included). Needs a window, not --headless.
## Run: flatpak run org.godotengine.Godot --path . --script res://tools/look_shots.gd [-- house street porch]
## Output: docs/look/look_<view>_<phase>.png

const ViewScript = preload("res://src/world/look_gate_view.gd")

const VIEWS := {
	"house": [Vector3(-15.0, 1.6, 3.0), Vector3(0.0, 2.4, -9.0)],
	"street": [Vector3(-32.0, 1.6, 0.4), Vector3(30.0, 2.2, -0.5)],
	"porch": [Vector3(-3.5, 1.6, -3.4), Vector3(-1.4, 1.5, -8.8)],
	"yard": [Vector3(-8.0, 1.6, -1.8), Vector3(-17.05, 0.2, 2.23)],   # the angle where the grass used to vanish
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/look"))
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	view.show_help(false)
	var wanted := OS.get_cmdline_user_args()
	for view_name in VIEWS:
		for phase in PS2Look.PHASE_NAMES:
			if not wanted.is_empty() and not wanted.has(view_name):
				continue
			view.set_phase(phase)
			var eye: Vector3 = VIEWS[view_name][0]
			var target: Vector3 = VIEWS[view_name][1]
			if phase == "night" and view_name != "street":
				# visibility is ~12 m at night (GDD): bring the camera closer or the subject is simply fogged out
				eye = Vector3(lerpf(eye.x, target.x, 0.5), eye.y, lerpf(eye.z, target.z, 0.5))
			view.set_camera(eye, target)
			for i in range(5):
				await RenderingServer.frame_post_draw
			var img := root.get_viewport().get_texture().get_image()
			var path := ProjectSettings.globalize_path("res://docs/look/look_%s_%s.png" % [view_name, phase])
			print("shot ", view_name, " ", phase, " ", img.get_size(), " err=", img.save_png(path))
	quit()
