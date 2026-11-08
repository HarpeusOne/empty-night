extends SceneTree

## Screenshots of the church model from the angles of the reference photos, so the model can be compared with them.
## Needs a window. Run: flatpak run org.godotengine.Godot --path . --script res://tools/church_shots.gd
## Output: docs/look/church_<view>.png

const ViewScript = preload("res://src/world/linia_view.gd")

# [view, phase, eye (s, t, y), target (s, t, y)] in the church's own frame (s along the nave, + = towards the tower)
const VIEWS := [
	["front_right", "day", [42.0, 20.0, 1.6], [15.0, 0.0, 9.0]],
	["front_left", "day", [40.0, -22.0, 1.6], [15.0, 0.0, 9.0]],
	["front", "day", [38.0, 0.0, 1.6], [15.0, 0.0, 9.0]],
	["side", "day", [-2.0, -26.0, 1.6], [0.0, 0.0, 6.0]],
	["back_far", "day", "search", [-22.7, 0.0, 3.0]],
	["tower_up", "day", [30.0, 9.0, 1.6], [15.0, 0.0, 17.0]],
	["front_dusk", "dusk", [32.0, 12.0, 1.6], [15.0, 0.0, 9.0]],
	["porch_close", "day", [26.0, 6.0, 1.6], [18.0, 0.0, 3.0]],
	["leanto_door", "day", [-3.0, -20.0, 1.7], [-1.0, -9.0, 1.8]],
	["belfry_above", "day", [25.0, 6.0, 24.0], [12.6, 0.0, 15.5]],
	["roofs_above", "day", [20.0, -14.0, 14.0], [10.0, -3.0, 5.0]],
	["roofs_above2", "day", [22.0, 13.0, 12.0], [10.0, 3.0, 5.0]],
	["junction_l", "day", [16.0, -16.0, 9.0], [9.4, -8.0, 5.0]],
	["junction_r", "day", [16.0, 16.0, 9.0], [9.4, 8.0, 5.0]],
	["junction_in_l", "day", [4.0, -14.0, 9.0], [9.4, -8.0, 5.0]],
	["side_a_rear", "day", [-22.0, -26.0, 6.0], [-14.0, -9.0, 2.5]],
	["side_b", "day", [-8.0, 26.0, 6.0], [-10.0, 9.0, 2.5]],
	["rear_above", "day", [-40.0, 10.0, 14.0], [-22.0, 0.0, 3.0]],
	["front_wings", "day", [28.0, -14.0, 10.0], [12.0, -5.0, 5.5]],
	["yard_street", "day", [48.0, 2.0, 1.7], [20.0, 0.0, 4.0]],
	["yard_air", "day", [46.0, -26.0, 24.0], [10.0, 0.0, 1.0]],
	["yard_left", "day", [24.0, -30.0, 1.7], [20.0, -12.0, 3.0]],
	["yard_cross", "day", [33.0, -9.0, 1.7], [24.5, -11.5, 3.5]],
	["front_night", "night", [26.0, 6.0, 1.6], [15.0, 0.0, 7.0]],
	# the author's photos of 2026-11-08: the rear with a bit of the left side, the whole right side from behind
	["photo_rear_left", "day", [-42.0, -22.0, 1.7], [-20.0, -2.0, 5.5]],
	["photo_right", "day", [-20.0, 36.0, 1.7], [-6.0, 0.0, 6.0]],
	["photo_rear", "day", [-48.0, 4.0, 3.0], [-22.0, 0.0, 6.0]],
]


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
	var level = view.world
	var fp = null
	for f in level.footprints:
		if f["kind"] == "church":
			fp = f
	var c := Vector2.ZERO
	for p in fp["ring"]:
		c += p
	c /= fp["ring"].size()
	var model := ChurchModel.new(null, Vector2(c.x, -c.y), level.CHURCH_HEADING_DEG)
	var wanted := OS.get_cmdline_user_args()
	for spec in VIEWS:
		if not wanted.is_empty() and not wanted.has(spec[0]):
			continue
		var t: Array = spec[3]
		var target := model.pt(t[0], t[1], t[2])
		var eye := Vector3.ZERO
		if typeof(spec[2]) == TYPE_STRING:
			# first spot behind the church that is not inside a building
			for dist in [14.0, 20.0, 26.0, 32.0, 40.0]:
				for lat in [0.0, 6.0, -6.0, 12.0, -12.0]:
					var cand := model.pt(-21.7 - dist, lat, 1.6)
					if level.point_in_footprint(Vector2(cand.x, cand.z)) == -1:
						eye = cand
						break
				if eye != Vector3.ZERO:
					break
		else:
			var e: Array = spec[2]
			eye = model.pt(e[0], e[1], e[2])
		if level.point_in_footprint(Vector2(eye.x, eye.z)) != -1:
			print("WARNING: the eye of '%s' is inside a building" % spec[0])
		view.set_phase(spec[1])
		view.set_camera(eye, target)
		for i in range(5):
			await RenderingServer.frame_post_draw
		var img := root.get_viewport().get_texture().get_image()
		print("shot ", spec[0], " err=", img.save_png(ProjectSettings.globalize_path("res://docs/look/church_%s.png" % spec[0])))
	quit()
