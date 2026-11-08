class_name PS2WorldBase
extends Node3D

## Shared base of the PS2-look worlds (the look-gate stage set and the OSM greybox of Linia): the sky, the
## per-phase light/fog values pushed into every surface material, and camera placement for tools.
## Subclasses fill `materials`, build geometry, and may override `_phase_lights` / `_on_phase`.

const DEV_WALKER = preload("res://src/dev/dev_walker.gd")

var materials: Dictionary = {}
var env: Environment
var walker: CharacterBody3D
var capture_mouse := true
var current_phase := "day"


func _make_environment() -> void:
	var sky_mat := ProceduralSkyMaterial.new()
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)


## Up to four point lights as [positions, colours] (Vector4 each). Default: none.
func _phase_lights(_p: Dictionary) -> Array:
	return [[Vector4(), Vector4(), Vector4(), Vector4()], [Vector4(), Vector4(), Vector4(), Vector4()]]


## Hook for subclass specifics (lit windows, lamp heads).
func _on_phase(_p: Dictionary) -> void:
	pass


## Debug: no fog at all (G in the view), to inspect the whole map from the air. Not a game phase.
var debug_fog_off := false


func set_phase(phase_name: String) -> void:
	current_phase = phase_name
	var p := PS2Look.phase(phase_name)
	if debug_fog_off:
		p["fog_start"] = 5000.0
		p["fog_end"] = 6000.0
	var lights := _phase_lights(p)
	for m in materials.values():
		PS2Look.apply_surface(m, p, lights[0], lights[1])
	var sky_mat := env.sky.sky_material as ProceduralSkyMaterial
	sky_mat.sky_top_color = p["sky_top"]
	sky_mat.sky_horizon_color = p["sky_horizon"]
	sky_mat.ground_horizon_color = p["sky_horizon"]
	sky_mat.ground_bottom_color = p["fog_color"]
	sky_mat.sky_energy_multiplier = 1.0
	sky_mat.ground_energy_multiplier = 1.0
	_on_phase(p)


## Puts the walker's eyes at `eye` looking at `target` (feet on the ground below).
func set_camera(eye: Vector3, target: Vector3) -> void:
	walker.global_position = Vector3(eye.x, maxf(eye.y - 1.6, 0.0) + 0.05, eye.z)
	var d := target - eye
	walker.call("set_view", atan2(-d.x, -d.z), atan2(d.y, Vector2(d.x, d.z).length()))
