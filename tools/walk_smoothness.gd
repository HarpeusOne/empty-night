extends SceneTree

## Measures how smoothly the camera moves while the walker walks along the road (the "everything shakes" bug).
## For every RENDERED frame it records the camera position and the time; a smooth walk moves the camera a
## little every frame at a constant speed. Physics-tick movement drawn faster than 60 Hz instead moves it in
## jumps with unchanged frames in between.
## Reports: the share of frames in which the camera did not move at all, and the coefficient of variation of the
## per-frame camera speed (0 = perfectly smooth). Needs a window; vsync is turned off to emulate a fast monitor.
## Run: flatpak run org.godotengine.Godot --path . --script res://tools/walk_smoothness.gd

const ViewScript = preload("res://src/world/look_gate_view.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	view.show_help(false)
	view.set_camera(Vector3(-30.0, 1.6, 0.4), Vector3(30.0, 1.6, 0.4))     # on the road, looking along it
	for i in range(20):
		await process_frame
	var walker = view.world.walker
	var cam: Camera3D = walker.get_viewport().get_camera_3d()
	for mode in [false, true]:
		walker.smooth_motion = mode
		view.set_camera(Vector3(-30.0, 1.6, 0.4), Vector3(30.0, 1.6, 0.4))
		for i in range(20):
			await process_frame
		walker.scripted_move = Vector2(0.0, -1.0)
		for i in range(30):
			await process_frame
		# camera speed in windows of 7 ms (what a 144 Hz display would show), for 3 s
		var window_us := 7000
		var speeds: Array = []
		var w_start := Time.get_ticks_usec()
		var w_pos := cam.global_position
		var t_end := w_start + 3_000_000
		var frames := 0
		while Time.get_ticks_usec() < t_end:
			await process_frame
			frames += 1
			var now := Time.get_ticks_usec()
			if now - w_start >= window_us:
				var pos := cam.global_position
				speeds.append(pos.distance_to(w_pos) / (float(now - w_start) / 1.0e6))
				w_start = now
				w_pos = pos
		walker.scripted_move = Vector2.ZERO
		var still := 0
		var mean := 0.0
		for v in speeds:
			mean += v
			if v < 0.05:
				still += 1
		mean /= maxf(speeds.size(), 1)
		var var_sum := 0.0
		for v in speeds:
			var_sum += (v - mean) * (v - mean)
		var cv := sqrt(var_sum / maxf(speeds.size(), 1)) / maxf(mean, 1.0e-9)
		print("%-34s windows: %d | no movement in %5.1f%% | mean speed %.2f m/s | speed variation (CV) %.2f" % [
			"physics tick (old)" if not mode else "every rendered frame (new)", speeds.size(), 100.0 * still / maxf(speeds.size(), 1), mean, cv])
	quit()
