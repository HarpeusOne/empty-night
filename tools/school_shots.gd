extends SceneTree

## Screenshots of the school model from the angles of the reference photos (src/key buildings/school/), so the
## model can be compared with them. Needs a window. Output: docs/look/school_<view>.png
## Run: flatpak run org.godotengine.Godot --path . --script res://tools/school_shots.gd [-- view ...]

const ViewScript = preload("res://src/world/linia_view.gd")

# [view, phase, eye (s, t, y), target (s, t, y)] in the school's frame (s towards the glazed hall gable, t towards
# the street Szkolna); the comment names the photo it matches
const VIEWS := [
	["street_corner", "day", [-14.0, 40.0, 1.7], [9.0, 12.0, 6.0]],      # 20-38-05: the wing and the porch from the street
	["street_hall", "day", [36.0, 40.0, 1.7], [36.0, 20.0, 4.5]],         # 20-38-27: the long side of the hall
	["porch", "day", [16.0, 36.0, 1.7], [8.0, 22.0, 4.0]],                # 20-38-21: the porch, stairs, hall door
	["north_gable", "day", [86.0, 38.0, 1.7], [58.0, 10.0, 6.5]],         # 20-38-37 / zvhvys: the glazed gable
	["yard", "day", [-40.0, -4.0, 1.7], [0.0, -6.0, 5.0]],                # 20-37-19: from the gate across the yard
	["wing_gable", "day", [-22.0, -14.0, 1.6], [0.0, 6.0, 7.0]],          # pfpqtj: the wing's south gable, canopy
	["field", "day", [-95.0, -20.0, 7.0], [5.0, -8.0, 6.0]],              # zfprzn / tkyvdp: from the field
	["air", "day", [-45.0, 55.0, 48.0], [18.0, -8.0, 0.0]],               # overview
	["air_west", "day", [10.0, -80.0, 40.0], [12.0, -10.0, 0.0]],         # overview of the old school
	["entrance", "day", [-16.0, -6.0, 1.7], [-1.0, -6.0, 2.2]],          # author's photo, round 3: the canopy over the footway
	["kitchen", "day", [-30.0, -16.0, 2.0], [0.0, -22.0, 3.5]],           # author's photo: kitchen door, low link
	["west_end", "day", [-32.0, -38.0, 2.0], [-12.3, -38.0, 4.0]],        # the west wing's blank end (grey stripe)
	["kitchen_side", "day", [-16.0, -2.0, 3.0], [-4.0, -12.0, 4.5]],
	["kitchen_east", "day", [-8.0, 2.0, 5.0], [-6.0, -12.0, 5.0]],      # the kitchen's east side and its roof edge
	["entrance_high", "day", [-13.0, -3.0, 6.5], [0.0, -6.0, 1.5]],      # author's round-2 shot: path, canopy, doors
	["canopy_side", "day", [-6.0, 4.0, 2.2], [-2.0, -8.0, 3.0]],          # the canopy against the wall
	["porch_stairs", "day", [-5.0, 31.0, 3.0], [5.0, 21.0, 2.5]],         # the stairs and their rails
	["link_roof", "day", [-8.0, -22.0, 9.0], [4.0, -34.0, 5.5]],          # the walls above the low roofs
	["entrance_air", "day", [-14.0, 6.0, 14.0], [0.0, -8.0, 2.0]],
	["dusk", "dusk", [-14.0, 40.0, 1.7], [9.0, 12.0, 6.0]],
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var only: Array = []
	for a in OS.get_cmdline_user_args():
		only.append(a)
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	view.show_help(false)
	var world = view.world
	var frame := SchoolModel.new(null)
	for spec in VIEWS:
		if not only.is_empty() and not (spec[0] in only):
			continue
		var e: Array = spec[2]
		var t: Array = spec[3]
		world.debug_fog_off = String(spec[1]) == "day"
		world.set_phase(String(spec[1]))
		view.set_camera(frame.pt(e[0], e[1], e[2]), frame.pt(t[0], t[1], t[2]))
		for i in range(5):
			await RenderingServer.frame_post_draw
		var img := root.get_viewport().get_texture().get_image()
		img.save_png(ProjectSettings.globalize_path("res://docs/look/school_%s.png" % spec[0]))
		print("shot ", spec[0])
	quit()
