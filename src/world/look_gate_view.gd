extends Control
class_name LookGateView

## Shows the look-gate world the way the game would: the 3D scene is rendered into a SubViewport at half
## the window size (640x480 in a 1280x960 window), upscaled with nearest filtering, then run through the
## PS2 post shader (banding + dither, desaturation, grain, vignette).
##
## Keys: 1 / 2 / 3 = day / dusk / night, P = post effect on/off, WASD + mouse = walk, Shift = faster,
## Esc = release the mouse, H = hide this text.

const WORLD = preload("res://src/world/look_gate_world.gd")

var capture_mouse := true
var world: PS2WorldBase
var post: ShaderMaterial
var _help: Label
var _post_on := true


func _ready() -> void:
	# Anchors AND offsets: with anchors alone the code-created view stayed 0x0 and nothing was drawn.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var container := SubViewportContainer.new()
	container.name = "View"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.stretch = true
	container.stretch_shrink = 2
	container.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	var viewport := SubViewport.new()
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	container.add_child(viewport)
	world = _make_world()
	world.capture_mouse = capture_mouse
	viewport.add_child(world)
	post = PS2Look.make_post_material()
	container.material = post
	_help = Label.new()
	_help.text = "1/2/3 faza (dzień/zmierzch/noc)   P efekt PS2   WASD + mysz   F latanie (Spacja/E góra, Ctrl/Q dół)   F2 edytor mapy   G mgła wł/wył   Shift szybciej   Esc mysz   H ukryj"
	_help.position = Vector2(12, 8)
	_help.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	_help.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_help.add_theme_constant_override("outline_size", 4)
	add_child(_help)
	set_phase("day")


## Subclasses return a different world (see LiniaView).
func _make_world() -> PS2WorldBase:
	return WORLD.new()


func set_phase(phase_name: String) -> void:
	world.set_phase(phase_name)
	PS2Look.apply_post(post, PS2Look.phase(phase_name))


func set_camera(eye: Vector3, target: Vector3) -> void:
	world.set_camera(eye, target)


func set_post_enabled(on: bool) -> void:
	_post_on = on
	post.set_shader_parameter("enabled", 1.0 if on else 0.0)


func show_help(on: bool) -> void:
	_help.visible = on


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		world.walker.call("apply_look", event.relative)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: set_phase("day")
			KEY_2: set_phase("dusk")
			KEY_3: set_phase("night")
			KEY_P: set_post_enabled(not _post_on)
			KEY_H: _help.visible = not _help.visible
			KEY_F: world.walker.call("toggle_fly")
			KEY_G:
				world.debug_fog_off = not world.debug_fog_off
				world.set_phase(world.current_phase)
