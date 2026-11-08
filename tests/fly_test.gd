extends SceneTree

## Fly mode: leaves the ground, passes through a wall, and fog can be switched off.
const ViewScript = preload("res://src/world/linia_view.gd")
var fails := 0

func check(ok: bool, msg: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + msg)
	if not ok:
		fails += 1

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	var w = view.world.walker
	w.set_fly(true)
	check(w._col.disabled, "collisions off in fly mode")
	var y0: float = w.global_position.y
	w.global_position.y = 60.0
	for i in range(10):
		await process_frame
	check(absf(w.global_position.y - 60.0) < 0.5, "no gravity while flying")
	w.set_fly(false)
	check(not w._col.disabled, "collisions back on when walking")
	view.world.debug_fog_off = true
	view.world.set_phase("day")
	var m = view.world.materials.values()[0]
	check(float(m.get_shader_parameter("fog_end")) > 1000.0, "fog switched off")
	view.world.debug_fog_off = false
	view.world.set_phase("day")
	check(float(m.get_shader_parameter("fog_end")) < 100.0, "fog back on")
	print("=== RESULT: %d failed ===" % fails)
	quit(1 if fails > 0 else 0)
