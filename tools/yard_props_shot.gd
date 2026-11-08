extends SceneTree

## The school yard props (2026-11-08) on an empty field outside the village (nothing is saved): green fence with
## a gate and a wicket, old trees, pollarded trees, flower beds, the church bench, a power line, a lamp pole and
## the pitch. Needs a window. Output: docs/look/yard_*.png
## Run: flatpak run org.godotengine.Godot --path . --script res://tools/yard_props_shot.gd
const ViewScript = preload("res://src/world/linia_view.gd")
const X0 := 700.0
const Z0 := 900.0


func _initialize() -> void:
	call_deferred("_run")


func _shot(view, name: String, eye: Vector3, target: Vector3) -> void:
	view.set_camera(eye, target)
	for i in range(4):
		await RenderingServer.frame_post_draw
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("res://docs/look/yard_%s.png" % name))
	print("shot ", name)


func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	view.show_help(false)
	var world = view.world
	var props: MapProps = world.props
	# the fence along the front with the gate and the wicket in gaps
	props.add_line("fence_green", [[X0 - 10.0, Z0], [X0 - 2.2, Z0]])
	props.add_point("gate_green", X0, Z0)
	props.add_line("fence_green", [[X0 + 2.2, Z0], [X0 + 8.0, Z0]])
	props.add_point("gate_small", X0 + 8.7, Z0)
	props.add_line("fence_green", [[X0 + 9.4, Z0], [X0 + 20.0, Z0], [X0 + 24.0, Z0 - 6.0]])
	# behind it: trees, flowers, benches
	props.add_point("tree_old", X0 - 6.0, Z0 - 8.0)
	props.add_point("tree_pollard", X0 + 4.0, Z0 - 6.0)
	props.add_point("tree_pollard", X0 + 10.0, Z0 - 7.0, 1.3, 1.2)
	props.add_point("tree_pollard", X0 + 16.0, Z0 - 6.5, 2.6, 0.9)
	props.add_point("flowers", X0 + 4.0, Z0 - 2.5)
	props.add_point("flowers", X0 - 4.0, Z0 - 2.5, 0.5)
	props.add_point("bench_plain", X0 + 7.0, Z0 - 2.5)
	props.add_point("bench", X0 + 12.0, Z0 - 2.5)
	# a power line along the road in front, a lamp pole, the pitch behind everything
	props.add_line("power_line", [[X0 - 20.0, Z0 + 6.0], [X0 + 10.0, Z0 + 6.0], [X0 + 38.0, Z0 + 4.0], [X0 + 50.0, Z0 - 12.0]])
	props.add_point("pole_lamp", X0 + 3.5, Z0 + 1.5, PI)
	props.add_point("pitch", X0 + 6.0, Z0 - 34.0)
	for i in range(4):
		await process_frame
	world.debug_fog_off = true
	world.set_phase("day")
	await _shot(view, "overview", Vector3(X0 + 4.0, 14.0, Z0 + 26.0), Vector3(X0 + 6.0, 0.0, Z0 - 14.0))
	await _shot(view, "gate", Vector3(X0 + 2.5, 1.7, Z0 + 7.0), Vector3(X0 + 3.0, 1.2, Z0))
	await _shot(view, "trees", Vector3(X0 + 6.0, 1.7, Z0 + 3.0), Vector3(X0 + 6.0, 4.0, Z0 - 7.0))
	await _shot(view, "power_line", Vector3(X0 + 18.0, 1.7, Z0 + 16.0), Vector3(X0 + 10.0, 5.0, Z0 + 6.0))
	await _shot(view, "pitch", Vector3(X0 - 18.0, 6.0, Z0 - 20.0), Vector3(X0 + 6.0, 0.0, Z0 - 34.0))
	world.debug_fog_off = false
	await _shot(view, "fog", Vector3(X0 + 2.0, 1.7, Z0 + 10.0), Vector3(X0 + 6.0, 2.0, Z0 - 10.0))
	quit()
