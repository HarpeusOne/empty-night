extends SceneTree

## Takes screenshots of the greybox from the real engine (needs a window, not --headless).
## Run: flatpak run org.godotengine.Godot --path . --script res://tools/shots.gd
## Output: docs/map/blockout_*.png

const LevelScene = preload("res://scenes/linia_centrum.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var level = LevelScene.instantiate()
	level.spawn_walker = false
	root.add_child(level)
	var cam := Camera3D.new()
	cam.far = 3000.0
	root.add_child(cam)
	cam.current = true
	for i in range(3):
		await process_frame
	var sp: Vector3 = level.spawn_position
	var church: Vector3 = level.church_position
	var school := Vector3(-112.0, 0.0, -193.0)
	var shots := [
		{"name": "blockout_overview", "pos": Vector3(0.0, 620.0, 430.0), "look": Vector3(0.0, 0.0, -30.0), "fov": 60.0},
		{"name": "blockout_church", "pos": sp + Vector3(0.0, 1.6, 0.0), "look": church + Vector3(0.0, 9.0, 0.0), "fov": 65.0},
		{"name": "blockout_school", "pos": Vector3(-30.0, 22.0, -105.0), "look": school + Vector3(0.0, 3.0, 0.0), "fov": 65.0},
		{"name": "blockout_street", "pos": sp + Vector3(0.0, 1.6, 0.0), "look": sp + Vector3(-60.0, 1.6, 8.0), "fov": 65.0},
	]
	for s in shots:
		cam.global_position = s["pos"]
		cam.fov = float(s["fov"])
		cam.look_at(s["look"], Vector3.UP)
		for i in range(4):
			await RenderingServer.frame_post_draw
		var img := root.get_viewport().get_texture().get_image()
		var path := ProjectSettings.globalize_path("res://docs/map/%s.png" % s["name"])
		var err := img.save_png(path)
		print("shot ", s["name"], " ", img.get_size(), " err=", err)
	quit()
