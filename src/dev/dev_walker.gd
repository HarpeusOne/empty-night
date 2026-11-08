extends CharacterBody3D
class_name DevWalker

## Minimal first-person walker for testing the greybox (WASD, mouse, Shift, Esc frees the mouse).
## Not the game's player: it only exists to walk around the blockout and bump into walls.

const GRAVITY := 24.0
const CAPSULE_RADIUS := 0.35
const CAPSULE_HEIGHT := 1.75

@export var walk_speed := 2.0
@export var sprint_speed := 4.2
@export var eye_height := 1.6
@export var mouse_sensitivity := 0.0025
## Set to false for screenshot tools and tests (no mouse capture).
@export var capture_mouse := true
## Tools and tests walk the walker without a keyboard: non-zero overrides WASD (x = right, y = backwards).
var scripted_move := Vector2.ZERO
var scripted_sprint := false
## true: move every rendered frame (smooth on any display); false: move on the 60 Hz physics tick (diagnostics only).
var smooth_motion := true

## Fly mode (F): no gravity, no collisions, moves along the view direction. For hunting texture / model / wall bugs.
var fly := false
## Map editor open: clicking must not capture the mouse (the editor needs the pointer).
var editor_mode := false
var fly_speed := 14.0
var fly_sprint_speed := 60.0

var _camera: Camera3D
var _pitch := 0.0
var _col: CollisionShape3D


func _ready() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = CAPSULE_RADIUS
	shape.height = CAPSULE_HEIGHT
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position = Vector3(0.0, CAPSULE_HEIGHT * 0.5, 0.0)
	add_child(col)
	_col = col
	_camera = Camera3D.new()
	_camera.position = Vector3(0.0, eye_height, 0.0)
	_camera.fov = 65.0
	_camera.near = 0.2    # a tiny near plane ruins depth precision at distance (z-fighting between flat layers)
	_camera.far = 800.0
	add_child(_camera)
	_camera.current = true
	if capture_mouse and DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_pitch = clampf(_pitch - event.relative.y * mouse_sensitivity, -1.4, 1.4)
		_camera.rotation.x = _pitch
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not editor_mode:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Mouse look driven from outside (the look-gate view forwards events itself, because the 3D world
## lives inside a SubViewport that does not receive them).
func apply_look(relative: Vector2) -> void:
	rotate_y(-relative.x * mouse_sensitivity)
	_pitch = clampf(_pitch - relative.y * mouse_sensitivity, -1.4, 1.4)
	_camera.rotation.x = _pitch


func get_camera() -> Camera3D:
	return _camera


func set_view(yaw: float, pitch: float) -> void:
	rotation.y = yaw
	_pitch = clampf(pitch, -1.4, 1.4)
	_camera.rotation.x = _pitch


## Moves in _process, not _physics_process: physics runs at 60 Hz, and a camera that only moves on physics ticks
## judders on any faster display (measured: it did not move at all in 98.8% of frames at 5000 FPS).
## move_and_slide() uses the frame delta when called from _process, so collisions still work.
func _process(delta: float) -> void:
	if smooth_motion:
		_move(delta)


func _physics_process(delta: float) -> void:
	if not smooth_motion:
		_move(delta)


func set_fly(on: bool) -> void:
	fly = on
	_col.disabled = on
	velocity = Vector3.ZERO
	if not on:
		# back to walking: stand upright and drop to the ground
		global_position.y = maxf(global_position.y, 0.0)


func toggle_fly() -> void:
	set_fly(not fly)


func _fly_move(delta: float) -> void:
	var cam_basis := _camera.global_transform.basis
	var move := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_W):
		move -= cam_basis.z
	if Input.is_physical_key_pressed(KEY_S):
		move += cam_basis.z
	if Input.is_physical_key_pressed(KEY_A):
		move -= cam_basis.x
	if Input.is_physical_key_pressed(KEY_D):
		move += cam_basis.x
	if Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_E):
		move += Vector3.UP
	if Input.is_physical_key_pressed(KEY_CTRL) or Input.is_physical_key_pressed(KEY_Q):
		move -= Vector3.UP
	var speed := fly_sprint_speed if Input.is_physical_key_pressed(KEY_SHIFT) else fly_speed
	if move != Vector3.ZERO:
		global_position += move.normalized() * speed * delta


func _move(delta: float) -> void:
	if fly:
		_fly_move(delta)
		return
	var input := scripted_move
	if input == Vector2.ZERO and Input.is_physical_key_pressed(KEY_W):
		input.y -= 1.0
	if scripted_move == Vector2.ZERO:
		if Input.is_physical_key_pressed(KEY_S):
			input.y += 1.0
		if Input.is_physical_key_pressed(KEY_A):
			input.x -= 1.0
		if Input.is_physical_key_pressed(KEY_D):
			input.x += 1.0
	var speed := sprint_speed if (scripted_sprint or Input.is_physical_key_pressed(KEY_SHIFT)) else walk_speed
	var dir := (global_transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	if is_on_floor():
		velocity.y = -0.1
	else:
		velocity.y -= GRAVITY * delta
	move_and_slide()
