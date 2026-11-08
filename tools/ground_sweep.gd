extends SceneTree

## Regression tool for the "grass disappears at some view angles" bug (found 2026-11-07).
##
## The far base ground (800 m, one huge quad) is painted solid magenta and the camera is swept around at
## several spots and pitches. Any magenta pixel whose view ray hits the ground INSIDE the dense grid and
## within 40 m of the camera means the far ground won the depth test over the fine grid.
## A positive control (the dense ground painted magenta) proves the detector can see it.
##
## Needs a window (not --headless) and takes about 100 s.
## Run: flatpak run org.godotengine.Godot --path . --script res://tools/ground_sweep.gd
## Exit code 0 = no frame shows the far ground through the dense grid.

const ViewScript = preload("res://src/world/look_gate_view.gd")

func _ground_hit(eye: Vector3, yaw: float, pitch: float, x: int, y: int, w: int, h: int) -> Vector3:
	var th := tan(deg_to_rad(65.0) * 0.5)
	var nx := ((x + 0.5) / w * 2.0 - 1.0) * th * (float(w) / h)
	var ny := (1.0 - (y + 0.5) / h * 2.0) * th
	var d := (Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch) * Vector3(nx, ny, -1.0)).normalized()
	if d.y >= -0.0001:
		return Vector3(1e9, 0, 1e9)
	return eye + d * (-eye.y / d.y)


func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	view.show_help(false)
	view.set_phase("day")
	var far: ShaderMaterial = view.world.materials["ground_far"]
	var mag := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	mag.fill(Color(1, 0, 1))
	var mag_tex := ImageTexture.create_from_image(mag)
	var grass_tex = (view.world.materials["ground"] as ShaderMaterial).get_shader_parameter("albedo_tex")
	far.set_shader_parameter("albedo_tex", mag_tex)      # the far base ground becomes solid magenta
	far.set_shader_parameter("fog_start", 1.0e6)           # no fog on it: fog would wash the magenta out to grey
	far.set_shader_parameter("fog_end", 2.0e6)
	var vp: SubViewport = view.get_node("View").get_child(0)
	var spots := [Vector3(-8, 1.6, -1.8), Vector3(0, 1.6, 0.4), Vector3(-20, 1.6, 2.5), Vector3(12, 1.6, -2.0), Vector3(-3, 1.6, -6.5)]
	# positive control: the DENSE ground painted magenta must be detected, otherwise the detector is blind
	var inner: ShaderMaterial = view.world.materials["ground"]
	inner.set_shader_parameter("albedo_tex", mag_tex)
	inner.set_shader_parameter("fog_start", 1.0e6)
	inner.set_shader_parameter("fog_end", 2.0e6)
	view.set_camera(Vector3(-8, 1.6, -1.8), Vector3(-8, -3.0, -11.0))
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var cimg := vp.get_texture().get_image()
	var ctrl := 0
	for y in range(0, cimg.get_height(), 4):
		for x in range(0, cimg.get_width(), 4):
			var cc := cimg.get_pixel(x, y)
			if cc.r > 0.4 and cc.b > 0.4 and cc.g < 0.25:
				ctrl += 1
	print("POSITIVE CONTROL (dense ground painted magenta): %d of %d samples detected" % [ctrl, (cimg.get_width() / 4) * (cimg.get_height() / 4)])
	inner.set_shader_parameter("albedo_tex", grass_tex)
	inner.set_shader_parameter("fog_start", 40.0)
	inner.set_shader_parameter("fog_end", 69.0)
	var total := 0
	var bad := 0
	var worst := 0
	for spot in spots:
		for pitch_deg in [-35, -20, -8, 0, 12]:
			for yaw_deg in range(0, 360, 6):
				var yaw := deg_to_rad(yaw_deg)
				var pitch := deg_to_rad(pitch_deg)
				var dir := Vector3(-sin(yaw) * cos(pitch), sin(pitch), -cos(yaw) * cos(pitch))
				view.set_camera(spot, spot + dir * 10.0)
				await RenderingServer.frame_post_draw
				await RenderingServer.frame_post_draw
				var img := vp.get_texture().get_image()
				var count := 0
				for y in range(0, img.get_height(), 4):
					for x in range(0, img.get_width(), 4):
						var c := img.get_pixel(x, y)
						if c.r > 0.4 and c.b > 0.4 and c.g < 0.25:
							var gp := _ground_hit(spot, yaw, pitch, x, y, img.get_width(), img.get_height())
							if gp.x > -58.0 and gp.x < 58.0 and gp.z > -38.0 and gp.z < 28.0 and gp.distance_to(spot) < 40.0:
								count += 1
				total += 1
				if count > 0:
					bad += 1
					worst = maxi(worst, count)
					if bad <= 25:
						print("MAGENTA at spot=%s yaw=%d pitch=%d samples=%d" % [spot, yaw_deg, pitch_deg, count])
	print("SWEEP DONE: frames=%d with-magenta=%d worst=%d samples (control detected %d)" % [total, bad, worst, ctrl])
	quit(0 if bad == 0 and ctrl > 1000 else 1)
