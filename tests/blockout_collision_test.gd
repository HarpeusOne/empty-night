extends SceneTree

## Automatic wall-collision test for the greybox (the thing that failed in the first attempt:
## "I can walk through walls"). Uses a real capsule body, not just ray casts.
## Run:
##   flatpak run org.godotengine.Godot --headless --path . --script res://tests/blockout_collision_test.gd
##
## For every wall (building edge >= MIN_EDGE) the capsule starts START_GAP metres outside its middle and
## is pushed PUSH metres towards the building. The wall passes only if the capsule is stopped
## and ends up outside every footprint. Edges whose start point lies inside another footprint are skipped
## (terraced or touching buildings) and counted, not hidden.

const LevelScene = preload("res://scenes/linia_centrum.tscn")

const CAPSULE_RADIUS := 0.35
const CAPSULE_HEIGHT := 1.75
const MIN_EDGE := 1.5
const START_GAP := 1.2
const PUSH := 3.0
const MAX_SKIPPED_FRACTION := 0.35
const MAX_ROOF_FAILURE_FRACTION := 0.03

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
	print("=== Empty Night blockout collision test ===")
	var level = LevelScene.instantiate()
	level.spawn_walker = false
	root.add_child(level)

	var body := CharacterBody3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = CAPSULE_RADIUS
	shape.height = CAPSULE_HEIGHT
	var cs := CollisionShape3D.new()
	cs.shape = shape
	cs.position = Vector3(0.0, CAPSULE_HEIGHT * 0.5, 0.0)
	body.add_child(cs)
	root.add_child(body)
	for i in range(3):
		await physics_frame

	_test_data(level)
	_test_ground(level)
	_test_spawn(level, body)
	_test_walls(level, body)

	print("=== RESULT: %d passed, %d failed ===" % [passes, failures.size()])
	for f in failures:
		print("  - ", f)
	quit(0 if failures.is_empty() else 1)


func _test_data(level) -> void:
	var n: int = level.footprints.size()
	_check(n >= 300, "greybox has %d buildings (expected >= 300)" % n)
	var visible: int = level.key_footprint_count()     # the church and the school
	for id in level.buildings.order:
		if not level.buildings.is_hidden(id):
			visible += 1
	_check(n == visible, "every visible building is a footprint (%d; OSM %d, author's changes in overrides.json)" % [visible, (level.data["buildings"] as Array).size()])
	var roof_frac := float(level.roof_failures) / maxf(float(n), 1.0)
	_check(roof_frac <= MAX_ROOF_FAILURE_FRACTION,
		"roof triangulation failed for %d of %d buildings (%.1f%%)" % [level.roof_failures, n, roof_frac * 100.0])
	_check(level.church_position.length() < 20.0, "the church stands at the origin (%.1f m away)" % level.church_position.length())


func _test_ground(level) -> void:
	var space := root.get_world_3d().direct_space_state
	var b: Dictionary = level.data["bounds"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261107
	var tested := 0
	var bad := 0
	for i in range(400):
		var x := rng.randf_range(float(b["xmin"]), float(b["xmax"]))
		var z := rng.randf_range(-float(b["ymax"]), -float(b["ymin"]))
		if level.point_in_footprint(Vector2(x, z)) != -1:
			continue
		var q := PhysicsRayQueryParameters3D.create(Vector3(x, 60.0, z), Vector3(x, -10.0, z))
		var hit := space.intersect_ray(q)
		tested += 1
		if hit.is_empty() or absf(float(hit["position"].y)) > 0.01:
			bad += 1
	_check(tested > 200 and bad == 0, "ground is solid at %d random points (%d holes)" % [tested, bad])


func _test_spawn(level, body: CharacterBody3D) -> void:
	var sp: Vector3 = level.spawn_position
	_check(level.point_in_footprint(Vector2(sp.x, sp.z)) == -1, "spawn point is not inside a building")
	body.global_position = sp + Vector3(0.0, 0.1, 0.0)
	var stuck := body.move_and_collide(Vector3(0.0, 0.0, 0.01), true)
	_check(stuck == null, "spawn capsule starts free (not embedded in a wall)")


func _test_walls(level, body: CharacterBody3D) -> void:
	var tested := 0
	var skipped := 0
	var failed := 0
	var shown := 0
	for f in level.footprints:
		var ring: PackedVector2Array = f["ring"]
		var outward_right := _signed_area(ring) > 0.0
		for i in range(ring.size()):
			var a := ring[i]
			var c := ring[(i + 1) % ring.size()]
			var d := c - a
			if d.length() < MIN_EDGE:
				continue
			var n := Vector2(d.y, -d.x) if outward_right else Vector2(-d.y, d.x)
			n = n.normalized()
			var mid := (a + c) * 0.5
			var start := mid + n * START_GAP
			if level.point_in_footprint(start) != -1:
				skipped += 1
				continue
			body.global_position = Vector3(start.x, 0.1, start.y)
			var motion := Vector3(-n.x, 0.0, -n.y) * PUSH
			var hit := body.move_and_collide(motion)
			var end := Vector2(body.global_position.x, body.global_position.z)
			tested += 1
			var stopped := hit != null and hit.get_travel().length() <= START_GAP
			var outside: bool = level.point_in_footprint(end) == -1
			if not (stopped and outside):
				failed += 1
				if shown < 10:
					shown += 1
					print("  WALL FAIL building %d edge %d: stopped=%s outside=%s travel=%.2f" % [
						f["id"], i, stopped, outside, 0.0 if hit == null else hit.get_travel().length()])
	var total := tested + skipped
	var skipped_frac := float(skipped) / maxf(float(total), 1.0)
	print("  walls: %d tested, %d skipped, %d failed" % [tested, skipped, failed])
	_check(tested >= 1500, "tested %d walls (expected >= 1500)" % tested)
	_check(failed == 0, "no wall can be walked through (%d of %d failed)" % [failed, tested])
	_check(skipped_frac <= MAX_SKIPPED_FRACTION,
		"only %.0f%% of walls skipped (limit %.0f%%); a high number would mean wrong outward normals" % [skipped_frac * 100.0, MAX_SKIPPED_FRACTION * 100.0])


static func _signed_area(ring: PackedVector2Array) -> float:
	var s := 0.0
	for i in range(ring.size()):
		var a := ring[i]
		var b := ring[(i + 1) % ring.size()]
		s += a.x * b.y - b.x * a.y
	return s * 0.5
