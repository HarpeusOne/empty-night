extends SceneTree

## Screenshots of the OSM greybox of Linia in the PS2 look: the spawn point and the four landmark
## buildings (church, town hall, fire station, school), in day / dusk / night. Needs a window.
## Run: flatpak run org.godotengine.Godot --path . --script res://tools/linia_shots.gd
## Output: docs/look/linia_<place>_<phase>.png

const ViewScript = preload("res://src/world/linia_view.gd")
const PLACES := {"kosciol": "church", "urzad": "townhall", "osp": "fire", "szkola": "school"}
# Distance from the building edge: bounded by the night visibility (12 m), so night shots stay close.
const DIST := {"day": 32.0, "dusk": 24.0, "night": 9.0}


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
	for i in range(3):
		await physics_frame
	var level = view.world
	var space := root.get_world_3d().direct_space_state
	print("greybox: %d buildings, %d gable, %d flat roofs, %d windows, built in %d ms" % [
		level.footprints.size(), level.gable_roofs, level.flat_roofs, level.window_count, level.build_ms])
	for place in PLACES:
		var fp = null
		for f in level.footprints:
			if f["kind"] == PLACES[place]:
				fp = f
		if fp == null:
			continue
		var ring: PackedVector2Array = fp["ring"]
		var c := Vector2.ZERO
		for v in ring:
			c += v
		c /= ring.size()
		var radius := 0.0
		for v in ring:
			radius = maxf(radius, v.distance_to(c))
		var target := Vector3(c.x, minf(float(fp["height"]), 6.0) * 0.55, c.y)
		for phase in PS2Look.PHASE_NAMES:
			var eye := Vector3.ZERO
			var found := false
			for k in range(16):
				var ang := TAU * float(k) / 16.0
				var dir := Vector2(cos(ang), sin(ang))
				var e2 := c + dir * (radius + float(DIST[phase]))
				var probe := c + dir * (radius + 2.0)
				if level.point_in_footprint(e2) != -1 or level.point_in_footprint(probe) != -1:
					continue
				var q := PhysicsRayQueryParameters3D.create(Vector3(e2.x, 1.6, e2.y), Vector3(probe.x, 1.6, probe.y))
				if not space.intersect_ray(q).is_empty():
					continue
				eye = Vector3(e2.x, 1.6, e2.y)
				found = true
				break
			if not found:
				print("no clear spot for ", place, " ", phase)
				continue
			view.set_phase(phase)
			view.set_camera(eye, target)
			for i in range(5):
				await RenderingServer.frame_post_draw
			var img := root.get_viewport().get_texture().get_image()
			var path := ProjectSettings.globalize_path("res://docs/look/linia_%s_%s.png" % [place, phase])
			print("shot ", place, " ", phase, " err=", img.save_png(path))
	# the spawn point looking at the church
	for phase in PS2Look.PHASE_NAMES:
		view.set_phase(phase)
		view.set_camera(level.spawn_position + Vector3(0, 1.6, 0), level.church_position + Vector3(0, 5.0, 0))
		for i in range(5):
			await RenderingServer.frame_post_draw
		var img2 := root.get_viewport().get_texture().get_image()
		print("shot start ", phase, " err=", img2.save_png(ProjectSettings.globalize_path("res://docs/look/linia_start_%s.png" % phase)))
	quit()
