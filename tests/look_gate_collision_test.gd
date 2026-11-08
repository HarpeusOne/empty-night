extends SceneTree

## Collision regression test for the look-gate stage set: ground, fence, the gate gap, the house wall and a
## pine trunk. A capsule the size of the walker is pushed at each; solid things must stop it, the gate must not.
## Run:
##   flatpak run org.godotengine.Godot --headless --path . --script res://tests/look_gate_collision_test.gd

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
	print("=== Trauma Village look-gate collision test ===")
	var world = WorldScript.new()
	world.capture_mouse = false
	root.add_child(world)
	var body := CharacterBody3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.35
	shape.height = 1.75
	var cs := CollisionShape3D.new()
	cs.shape = shape
	cs.position = Vector3(0.0, 0.875, 0.0)
	body.add_child(cs)
	root.add_child(body)
	for i in range(3):
		await physics_frame

	# ground
	var space := root.get_world_3d().direct_space_state
	var bad := 0
	for p in [Vector2(-20, 10), Vector2(0, 0), Vector2(15, -2), Vector2(-30, -20), Vector2(25, 12), Vector2(0, -3)]:
		var q := PhysicsRayQueryParameters3D.create(Vector3(p.x, 20.0, p.y), Vector3(p.x, -5.0, p.y))
		q.exclude = [body.get_rid(), world.walker.get_rid()]   # the test capsule itself stands at the origin
		var hit := space.intersect_ray(q)
		if hit.is_empty() or absf(float(hit["position"].y)) > 0.01:
			bad += 1
	_check(bad == 0, "ground is solid at 6 points (%d holes)" % bad)

	# the walker spawns free
	var walker: CharacterBody3D = world.walker
	# The walker now falls and rests on the ground at once; lift it a little so the probe does not report the floor.
	walker.global_position += Vector3(0.0, 0.1, 0.0)
	_check(walker.move_and_collide(Vector3(0, 0, 0.01), true) == null, "the walker spawns free (not embedded in anything)")

	# fence blocks
	var end := _push(body, Vector3(-6.0, 0.1, -3.5), Vector3(0, 0, -3.0))
	_check(end["hit"] and end["z"] > world.FENCE_Z, "the fence stops the walker (ends at z=%.2f, fence at %.1f)" % [end["z"], world.FENCE_Z])

	# the gate gap lets through
	end = _push(body, Vector3(world.GATE_X, 0.1, -3.5), Vector3(0, 0, -2.0))
	_check(not end["hit"] and end["z"] < world.FENCE_Z - 0.3, "the gate gap lets the walker through the fence line (ends at z=%.2f, fence at %.1f)" % [end["z"], world.FENCE_Z])

	# house wall blocks (front wall plane at z = HOUSE.z + D/2)
	var wall_z: float = world.HOUSE.z + world.HOUSE_D * 0.5
	end = _push(body, Vector3(3.0, 0.1, -6.0), Vector3(0, 0, -4.0))
	_check(end["hit"] and end["z"] > wall_z, "the house wall stops the walker (ends at z=%.2f, wall at %.1f)" % [end["z"], wall_z])

	# the side of the house too
	var side_x: float = world.HOUSE.x + world.HOUSE_W * 0.5
	end = _push(body, Vector3(side_x + 3.0, 0.1, world.HOUSE.z), Vector3(-5.0, 0, 0))
	_check(end["hit"] and end["x"] > side_x, "the house side wall stops the walker (ends at x=%.2f, wall at %.1f)" % [end["x"], side_x])

	# a pine trunk at (7, 0, 7.5)
	end = _push(body, Vector3(7.0, 0.1, 5.5), Vector3(0, 0, 4.0))
	_check(end["hit"] and end["z"] < 7.5, "the pine trunk stops the walker (ends at z=%.2f, trunk at 7.5)" % end["z"])

	print("=== RESULT: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("  - ", f)
	quit(0 if failures.is_empty() else 1)


func _push(body: CharacterBody3D, start: Vector3, motion: Vector3) -> Dictionary:
	body.global_position = start
	var hit := body.move_and_collide(motion)
	return {"hit": hit != null, "x": body.global_position.x, "z": body.global_position.z}
