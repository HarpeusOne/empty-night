extends SceneTree

## Performance of the OSM greybox in the PS2 look, against the budget in docs/GDD.md (BAL-48/49/50):
## <= 250 draw calls, <= 350k triangles per frame, load <= 8 s, 60 FPS. Needs a window (vsync is turned off
## to see the headroom). Run: flatpak run org.godotengine.Godot --path . --script res://tools/linia_perf.gd

const ViewScript = preload("res://src/world/linia_view.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var t0 := Time.get_ticks_msec()
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	var load_ms := Time.get_ticks_msec() - t0
	view.show_help(false)
	var level = view.world
	print("load: %d ms (level build %d ms) | %d buildings, %d gable / %d flat roofs, %d windows" % [
		load_ms, level.build_ms, level.footprints.size(), level.gable_roofs, level.flat_roofs, level.window_count])
	var spots := {
		"start": [level.spawn_position + Vector3(0, 1.6, 0), level.church_position + Vector3(0, 5, 0)],
		"church": [level.church_position + Vector3(30, 1.6, 30), level.church_position + Vector3(0, 5, 0)],
		"edge": [Vector3(-300, 1.6, 100), Vector3(0, 3, -50)],
	}
	for phase in PS2Look.PHASE_NAMES:
		view.set_phase(phase)
		for spot in spots:
			view.set_camera(spots[spot][0], spots[spot][1])
			for i in range(30):
				await process_frame
			var t_start := Time.get_ticks_usec()
			var calls := 0
			var prims := 0
			var frames := 120
			for i in range(frames):
				await process_frame
				calls = maxi(calls, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
				prims = maxi(prims, int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
			var ms := float(Time.get_ticks_usec() - t_start) / 1000.0 / frames
			print("%-5s %-6s %6.2f ms/frame (%5.0f FPS)  draw calls %3d  triangles %7d" % [phase, spot, ms, 1000.0 / ms, calls, prims])
	quit()
