extends SceneTree

## The walker must move every rendered frame at the right speed and stay on the ground (the road/camera
## "shaking" bug: it used to move only on 60 Hz physics ticks).
## Run: flatpak run org.godotengine.Godot --headless --path . --script res://tests/walker_motion_test.gd

const WorldScript = preload("res://src/world/look_gate_world.gd")

var failures: Array[String] = []
var passes := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, label: String) -> void:
	if condition:
		passes += 1
		print("PASS  ", label)
	else:
		failures.append(label)
		push_error("FAIL  " + label)
		print("FAIL  ", label)


func _run() -> void:
	print("=== Empty Night walker motion test ===")
	var world = WorldScript.new()
	world.capture_mouse = false
	root.add_child(world)
	for i in range(5):
		await physics_frame
	var walker = world.walker
	_check(walker.smooth_motion, "the walker moves every rendered frame by default")
	world.set_camera(Vector3(-30.0, 1.6, 0.4), Vector3(30.0, 1.6, 0.4))     # on the road, looking along it
	for i in range(20):
		await process_frame
	var start: Vector3 = walker.global_position
	var y_min := start.y
	var y_max := start.y
	var moved_frames := 0
	var frames := 0
	var last: Vector3 = start
	walker.scripted_move = Vector2(0.0, -1.0)
	var t0 := Time.get_ticks_usec()
	while Time.get_ticks_usec() - t0 < 1_500_000:
		await process_frame
		frames += 1
		var p: Vector3 = walker.global_position
		if p.distance_to(last) > 1.0e-7:
			moved_frames += 1
		last = p
		y_min = minf(y_min, p.y)
		y_max = maxf(y_max, p.y)
	var elapsed := float(Time.get_ticks_usec() - t0) / 1.0e6
	walker.scripted_move = Vector2.ZERO
	var speed := Vector2(last.x - start.x, last.z - start.z).length() / elapsed
	_check(float(moved_frames) / maxf(frames, 1) > 0.97, "the walker moved in %.0f%% of rendered frames (>97%% needed)" % (100.0 * moved_frames / maxf(frames, 1)))
	_check(absf(speed - 2.0) < 0.15, "walking speed is about 2.0 m/s (measured %.2f)" % speed)
	_check(y_max - y_min < 0.005, "the walker stays on the ground, no vertical jitter (range %.1f mm)" % ((y_max - y_min) * 1000.0))
	print("=== RESULT: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("  - ", f)
	quit(0 if failures.is_empty() else 1)
