class_name PS2Look
extends RefCounted

## The PS2 look: the three phases of the day as one set of numbers (light, fog, sky, colour grade) plus
## material helpers. One geometry, three moods (docs/day-night.md): only these values change per phase.

const SURFACE_SHADER := preload("res://src/shaders/ps2_surface.gdshader")
const POST_SHADER := preload("res://src/shaders/ps2_post.gdshader")
const TEXTURE_DIR := "res://art/textures/"

const PHASE_NAMES := ["day", "dusk", "night"]


## Loads a texture straight from the PNG so it works before the editor has imported it.
static func load_texture(tex_name: String) -> ImageTexture:
	var img := Image.load_from_file(ProjectSettings.globalize_path(TEXTURE_DIR + tex_name + ".png"))
	img.generate_mipmaps()      # without them the asphalt cracks crawl and shimmer as you move
	return ImageTexture.create_from_image(img)


static func make_material(tex_name: String, tint: Color = Color.WHITE) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = SURFACE_SHADER
	m.set_shader_parameter("albedo_tex", load_texture(tex_name))
	m.set_shader_parameter("tint", tint)
	return m


static func make_post_material() -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = POST_SHADER
	return m


static func phase(phase_name: String) -> Dictionary:
	# Fog is on in EVERY phase; only the visibility range changes with the time of day (GDD section 5:
	# day 60 m, dusk 35 m, night 12 m, 20 m with a flashlight). fog_end is 15% beyond the nominal range so an
	# object right at that distance is still faintly visible; fog_start is 10% of it.
	match phase_name:
		"dusk":
			return {
				"visibility": 35.0,
				"sun_dir": Vector3(0.85, -0.12, -0.25), "sun_color": Color(0.85, 0.62, 0.42) * 0.40,
				"ambient": Color(0.36, 0.37, 0.44), "fog_color": Color(0.36, 0.33, 0.36),
				"fog_start": 3.5, "fog_end": 40.0,
				"sky_top": Color(0.20, 0.21, 0.27), "sky_horizon": Color(0.36, 0.33, 0.36),
				"lamp": 2.4, "window": 1.4, "window_emission": 0.7,
				"post": {"saturation": 0.55, "contrast": 1.06, "tint": Color(1.0, 0.95, 0.90), "grain": 0.06, "vignette": 0.45},
			}
		"night":
			return {
				"visibility": 12.0,
				"sun_dir": Vector3(0.45, -0.75, -0.45), "sun_color": Color(0.28, 0.36, 0.58) * 0.7,
				"ambient": Color(0.19, 0.22, 0.34), "fog_color": Color(0.08, 0.10, 0.16),
				"fog_start": 1.2, "fog_end": 14.0,
				"sky_top": Color(0.03, 0.04, 0.08), "sky_horizon": Color(0.08, 0.10, 0.16),
				"lamp": 4.8, "window": 2.6, "window_emission": 1.0,
				"post": {"saturation": 0.50, "contrast": 1.10, "tint": Color(0.88, 0.94, 1.0), "grain": 0.085, "vignette": 0.60},
			}
		_:
			return {
				"visibility": 60.0,
				"sun_dir": Vector3(0.40, -0.80, -0.30), "sun_color": Color(0.80, 0.80, 0.76) * 0.35,
				"ambient": Color(0.62, 0.65, 0.68), "fog_color": Color(0.60, 0.63, 0.64),
				"fog_start": 6.0, "fog_end": 69.0,
				"sky_top": Color(0.52, 0.57, 0.62), "sky_horizon": Color(0.60, 0.63, 0.64),
				"lamp": 0.0, "window": 0.0, "window_emission": 0.0,
				"post": {"saturation": 0.58, "contrast": 1.02, "tint": Color(0.94, 0.98, 1.0), "grain": 0.05, "vignette": 0.38},
			}


## Pushes the light / fog values of a phase into one surface material.
static func apply_surface(m: ShaderMaterial, p: Dictionary, point_pos: Array, point_col: Array) -> void:
	m.set_shader_parameter("sun_dir", p["sun_dir"])
	m.set_shader_parameter("sun_color", p["sun_color"])
	m.set_shader_parameter("ambient_color", p["ambient"])
	m.set_shader_parameter("fog_color", p["fog_color"])
	m.set_shader_parameter("fog_start", p["fog_start"])
	m.set_shader_parameter("fog_end", p["fog_end"])
	for i in range(4):
		m.set_shader_parameter("pl_pos%d" % i, point_pos[i])
		m.set_shader_parameter("pl_col%d" % i, point_col[i])


static func apply_post(m: ShaderMaterial, p: Dictionary) -> void:
	var post: Dictionary = p["post"]
	for k in post:
		m.set_shader_parameter(k, post[k])
