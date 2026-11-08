extends PS2WorldBase
class_name LookGateWorld

## "Look gate" stage set: one street and one typical Linia house (single storey + attic, gable roof,
## plastered walls, fence, pines, utility pole, street lamp). Used to judge the PS2 look in day, dusk
## and night before any more of the map is built. The house size is the median of the OSM houses
## (about 11 x 8.5 m); everything else is a stage prop, not a real place.
##
## World: +X east along the road, the road is on z = 0, the house stands at z = -13 facing +Z.

const HOUSE_W := 10.8
const HOUSE_D := 8.4
const WALL_H := 2.7
const OVERHANG := 0.5
const OVERHANG_END := 0.4
const PITCH_TAN := 0.70                      # about 35 degrees
const HOUSE := Vector3(0.0, 0.0, -13.0)
const ROAD_HALF := 2.5
const SHOULDER := 1.2
const FENCE_Z := -5.0
const GATE_X := -1.4

const DIRT := Color(0.44, 0.42, 0.38)         # baked grime / ambient occlusion at the foot of walls

var lamp_pos := Vector3(5.8, 6.0, -1.9)
var window_glow_pos := Vector3(1.6, 1.6, -8.2)


func _ready() -> void:
	_make_materials()
	_make_environment()
	_build_scene()
	_spawn_walker()
	set_phase("day")


func _make_materials() -> void:
	materials = {
		"ground": PS2Look.make_material("grass"),
		"ground_far": PS2Look.make_material("grass"),
		"road": PS2Look.make_material("asphalt"),
		"gravel": PS2Look.make_material("gravel"),
		"wall": PS2Look.make_material("plaster_cream"),
		"concrete": PS2Look.make_material("plaster_grey"),
		"roof": PS2Look.make_material("roof_tiles_red"),
		"win": PS2Look.make_material("window_dark"),
		"win_lit": PS2Look.make_material("window_dark"),
		"door": PS2Look.make_material("door_wood"),
		"fence": PS2Look.make_material("fence_planks"),
		"bark": PS2Look.make_material("bark"),
		"foliage": PS2Look.make_material("foliage"),
		"brick": PS2Look.make_material("brick"),
		"wire": PS2Look.make_material("asphalt", Color(0.25, 0.25, 0.27)),
		"pole": PS2Look.make_material("plaster_grey", Color(0.45, 0.46, 0.48)),
		"lamp": PS2Look.make_material("plaster_grey", Color(1.0, 0.85, 0.45)),
	}


func _phase_lights(p: Dictionary) -> Array:
	var lamp_e: float = p["lamp"]
	var win_e: float = p["window"]
	# old street lamps and bulbs: yellow, not white
	return [[Vector4(lamp_pos.x, lamp_pos.y, lamp_pos.z, 26.0), Vector4(window_glow_pos.x, window_glow_pos.y, window_glow_pos.z, 10.0), Vector4(), Vector4()],
		[Vector4(1.0, 0.80, 0.38, 0.0) * lamp_e, Vector4(1.0, 0.74, 0.32, 0.0) * win_e, Vector4(), Vector4()]]


func _on_phase(p: Dictionary) -> void:
	var lit: bool = float(p["window_emission"]) > 0.0
	(materials["win_lit"] as ShaderMaterial).set_shader_parameter("albedo_tex", PS2Look.load_texture("window_lit" if lit else "window_dark"))
	(materials["win_lit"] as ShaderMaterial).set_shader_parameter("emission_strength", float(p["window_emission"]))
	(materials["lamp"] as ShaderMaterial).set_shader_parameter("emission_strength", 1.6 if float(p["lamp"]) > 0.0 else 0.0)


# ------------------------------------------------------------------ scene

func _h(x: float, y: float, z: float) -> Vector3:
	return HOUSE + Vector3(x, y, z)


func _build_scene() -> void:
	var lp := LowPoly.new()
	var body := StaticBody3D.new()
	body.name = "Colliders"
	add_child(body)
	_ground(lp, body)
	_road(lp)
	_house(lp, body)
	_fence(lp, body)
	for t in [[Vector3(-10.5, 0, -9.5), 1.0], [Vector3(10.5, 0, -11.0), 1.15], [Vector3(7.0, 0, 7.5), 1.0],
			[Vector3(-16.0, 0, -3.0), 0.9], [Vector3(15.0, 0, 6.0), 1.1], [Vector3(-4.0, 0, -22.0), 1.2]]:
		_pine(lp, body, t[0], t[1])
	_poles(lp)
	var mi := MeshInstance3D.new()
	mi.name = "Stage"
	mi.mesh = lp.build(materials)
	add_child(mi)


func _collider(body: StaticBody3D, center: Vector3, size: Vector3) -> void:
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	cs.position = center
	body.add_child(cs)


func _grid(lp: LowPoly, key: String, x0: float, x1: float, z0: float, z1: float, y: float, cell: float, uv_scale: float = 4.0) -> void:
	var nu := maxi(int(ceil((x1 - x0) / cell)), 1)
	var nv := maxi(int(ceil((z1 - z0) / cell)), 1)
	lp.quad_grid(key, Vector3(x0, y, z1), Vector3(x1, y, z1), Vector3(x1, y, z0), Vector3(x0, y, z0),
		Vector2(x0, z1) / uv_scale, Vector2(x1, z1) / uv_scale, Vector2(x1, z0) / uv_scale, Vector2(x0, z0) / uv_scale,
		Color.WHITE, Color.WHITE, nu, nv)


func _ground(lp: LowPoly, body: StaticBody3D) -> void:
	# One big ground below everything, so the cracks (T-junctions) between differently subdivided grids
	# show grass instead of sky; the fine grid on top is what vertex lighting needs near the camera.
	_grid(lp, "ground_far", -400.0, 400.0, -400.0, 400.0, -0.3, 800.0)
	_grid(lp, "ground", -60.0, 60.0, -40.0, 30.0, 0.0, 2.0)
	_collider(body, Vector3(0, -0.5, 0), Vector3(800, 1, 800))


func _road(lp: LowPoly) -> void:
	for seg in [[-300.0, -60.0, 20.0], [-60.0, 60.0, 2.0], [60.0, 300.0, 20.0]]:
		_grid(lp, "road", seg[0], seg[1], -ROAD_HALF, ROAD_HALF, 0.08, seg[2])
		_grid(lp, "gravel", seg[0], seg[1], ROAD_HALF, ROAD_HALF + SHOULDER, 0.04, seg[2])
		_grid(lp, "gravel", seg[0], seg[1], -ROAD_HALF - SHOULDER, -ROAD_HALF, 0.04, seg[2])
	# gravel path from the gate to the porch
	_grid(lp, "gravel", GATE_X - 0.5, GATE_X + 0.5, -8.6, FENCE_Z, 0.04, 1.0, 2.0)


# ------------------------------------------------------------------ house

func _wall_quad(lp: LowPoly, key: String, wall: String, along: float, y_center: float, w: float, h: float, off: float = 0.03) -> void:
	var y0 := y_center - h * 0.5
	var y1 := y_center + h * 0.5
	var z1 := HOUSE_D * 0.5
	var z0 := -HOUSE_D * 0.5
	var x1 := HOUSE_W * 0.5
	var x0 := -HOUSE_W * 0.5
	var a: Vector3
	var b: Vector3
	var c: Vector3
	var d: Vector3
	match wall:
		"front":
			a = _h(along - w * 0.5, y0, z1 + off); b = _h(along + w * 0.5, y0, z1 + off)
			c = _h(along + w * 0.5, y1, z1 + off); d = _h(along - w * 0.5, y1, z1 + off)
		"back":
			a = _h(along + w * 0.5, y0, z0 - off); b = _h(along - w * 0.5, y0, z0 - off)
			c = _h(along - w * 0.5, y1, z0 - off); d = _h(along + w * 0.5, y1, z0 - off)
		"right":
			a = _h(x1 + off, y0, along + w * 0.5); b = _h(x1 + off, y0, along - w * 0.5)
			c = _h(x1 + off, y1, along - w * 0.5); d = _h(x1 + off, y1, along + w * 0.5)
		_:
			a = _h(x0 - off, y0, along - w * 0.5); b = _h(x0 - off, y0, along + w * 0.5)
			c = _h(x0 - off, y1, along + w * 0.5); d = _h(x0 - off, y1, along - w * 0.5)
	lp.quad_grid(key, a, b, c, d, Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0))


func _house(lp: LowPoly, body: StaticBody3D) -> void:
	var x0 := -HOUSE_W * 0.5
	var x1 := HOUSE_W * 0.5
	var z0 := -HOUSE_D * 0.5
	var z1 := HOUSE_D * 0.5
	var rise := z1 * PITCH_TAN
	var rh := WALL_H + rise
	var ye := WALL_H - OVERHANG * PITCH_TAN
	var top := Color.WHITE
	var nlen := maxi(int(ceil(HOUSE_W / 1.8)), 1)
	var ndep := maxi(int(ceil(HOUSE_D / 1.8)), 1)
	var vtop := 0.0
	var vbot := WALL_H / 3.0
	# four walls
	lp.quad_grid("wall", _h(x0, 0, z1), _h(x1, 0, z1), _h(x1, WALL_H, z1), _h(x0, WALL_H, z1),
		Vector2(0, vbot), Vector2(HOUSE_W / 3.0, vbot), Vector2(HOUSE_W / 3.0, vtop), Vector2(0, vtop), DIRT, top, nlen, 2)
	lp.quad_grid("wall", _h(x1, 0, z0), _h(x0, 0, z0), _h(x0, WALL_H, z0), _h(x1, WALL_H, z0),
		Vector2(0, vbot), Vector2(HOUSE_W / 3.0, vbot), Vector2(HOUSE_W / 3.0, vtop), Vector2(0, vtop), DIRT, top, nlen, 2)
	lp.quad_grid("wall", _h(x1, 0, z1), _h(x1, 0, z0), _h(x1, WALL_H, z0), _h(x1, WALL_H, z1),
		Vector2(0, vbot), Vector2(HOUSE_D / 3.0, vbot), Vector2(HOUSE_D / 3.0, vtop), Vector2(0, vtop), DIRT, top, ndep, 2)
	lp.quad_grid("wall", _h(x0, 0, z0), _h(x0, 0, z1), _h(x0, WALL_H, z1), _h(x0, WALL_H, z0),
		Vector2(0, vbot), Vector2(HOUSE_D / 3.0, vbot), Vector2(HOUSE_D / 3.0, vtop), Vector2(0, vtop), DIRT, top, ndep, 2)
	# gable triangles
	lp.tri_flat("wall", _h(x1, WALL_H, z1), _h(x1, WALL_H, z0), _h(x1, rh, 0.0),
		Vector2(0, 0), Vector2(HOUSE_D / 3.0, 0), Vector2(HOUSE_D / 6.0, -rise / 3.0))
	lp.tri_flat("wall", _h(x0, WALL_H, z0), _h(x0, WALL_H, z1), _h(x0, rh, 0.0),
		Vector2(0, 0), Vector2(HOUSE_D / 3.0, 0), Vector2(HOUSE_D / 6.0, -rise / 3.0))
	# roof (two planes with overhang)
	var ox := OVERHANG_END
	var slope := Vector2(rh - ye, z1 + OVERHANG).length()
	var ru0 := (x0 - ox) / 2.0
	var ru1 := (x1 + ox) / 2.0
	lp.quad_grid("roof", _h(x0 - ox, ye, z1 + OVERHANG), _h(x1 + ox, ye, z1 + OVERHANG), _h(x1 + ox, rh, 0.0), _h(x0 - ox, rh, 0.0),
		Vector2(ru0, slope / 2.0), Vector2(ru1, slope / 2.0), Vector2(ru1, 0), Vector2(ru0, 0), Color(0.82, 0.8, 0.8), top, nlen + 1, 3)
	lp.quad_grid("roof", _h(x1 + ox, ye, z0 - OVERHANG), _h(x0 - ox, ye, z0 - OVERHANG), _h(x0 - ox, rh, 0.0), _h(x1 + ox, rh, 0.0),
		Vector2(ru0, slope / 2.0), Vector2(ru1, slope / 2.0), Vector2(ru1, 0), Vector2(ru0, 0), Color(0.82, 0.8, 0.8), top, nlen + 1, 3)
	# underside of the eaves, so the overhang is not see-through from the street
	lp.tri_flat("concrete", _h(x1 + ox, ye, z1 + OVERHANG), _h(x0 - ox, ye, z1 + OVERHANG), _h(x0 - ox, WALL_H, z1),
		Vector2(0, 0), Vector2(5, 0), Vector2(5, 1), Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5))
	lp.tri_flat("concrete", _h(x1 + ox, ye, z1 + OVERHANG), _h(x0 - ox, WALL_H, z1), _h(x1 + ox, WALL_H, z1),
		Vector2(0, 0), Vector2(5, 1), Vector2(0, 1), Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5))
	# windows (front, sides, back, attic) and the door
	for wx in [-4.0, 1.6, 4.2]:
		_wall_quad(lp, "win_lit" if is_equal_approx(wx, 1.6) else "win", "front", wx, 1.55, 1.2, 1.3)
	for wz in [-1.8, 1.6]:
		_wall_quad(lp, "win", "right", wz, 1.55, 1.1, 1.3)
	_wall_quad(lp, "win", "left", 0.0, 1.55, 1.1, 1.3)
	for wx in [-3.0, 0.5, 3.8]:
		_wall_quad(lp, "win", "back", wx, 1.55, 1.2, 1.3)
	_wall_quad(lp, "win", "right", 0.0, WALL_H + 0.95, 0.7, 0.8)
	_wall_quad(lp, "win", "left", 0.0, WALL_H + 0.95, 0.7, 0.8)
	_wall_quad(lp, "door", "front", GATE_X, 1.05, 1.0, 2.1)
	# porch: canopy on two posts, a step
	lp.box("concrete", _h(GATE_X, 2.42, z1 + 0.7), Vector3(2.3, 0.12, 1.4), 2.0)
	for px in [GATE_X - 1.0, GATE_X + 1.0]:
		lp.box("bark", _h(px, 1.2, z1 + 1.25), Vector3(0.12, 2.4, 0.12), 1.5)
	lp.box("concrete", _h(GATE_X, 0.1, z1 + 0.5), Vector3(1.6, 0.2, 1.0), 1.5)
	# chimney
	lp.box("brick", _h(3.0, rh - 0.05, -0.9), Vector3(0.7, 1.9, 0.7), 1.0)
	# collision for the walker
	_collider(body, HOUSE + Vector3(0, 3.0, 0), Vector3(HOUSE_W, 6.0, HOUSE_D))


# ------------------------------------------------------------------ fence, trees, poles

func _fence(lp: LowPoly, body: StaticBody3D) -> void:
	for seg in [[-9.0, GATE_X - 0.55], [GATE_X + 0.55, 9.0]]:
		var a: float = seg[0]
		var b: float = seg[1]
		lp.box("fence", Vector3((a + b) * 0.5, 0.55, FENCE_Z), Vector3(b - a, 1.1, 0.06), 1.1, Color(0.7, 0.68, 0.66), Color.WHITE, 1.5)
		_collider(body, Vector3((a + b) * 0.5, 0.65, FENCE_Z), Vector3(b - a, 1.3, 0.2))
	var px := -9.0
	while px <= 9.01:
		lp.box("bark", Vector3(px, 0.65, FENCE_Z), Vector3(0.13, 1.3, 0.13), 1.5)
		px += 3.0
	for gx in [GATE_X - 0.55, GATE_X + 0.55]:
		lp.box("bark", Vector3(gx, 0.7, FENCE_Z), Vector3(0.16, 1.4, 0.16), 1.5)
	lp.box("foliage", Vector3(6.5, 0.55, FENCE_Z - 0.9), Vector3(5.0, 1.1, 1.0), 1.2, Color(0.6, 0.6, 0.6), Color.WHITE, 1.5)
	_collider(body, Vector3(6.5, 0.6, FENCE_Z - 0.9), Vector3(5.0, 1.2, 1.0))


func _pine(lp: LowPoly, body: StaticBody3D, pos: Vector3, s: float) -> void:
	lp.cylinder("bark", pos, 0.28 * s, 9.0 * s, 6, Color(0.55, 0.55, 0.55), Color.WHITE, 2.0)
	for c in [[2.6, 2.6, 3.0], [4.4, 2.1, 2.8], [6.0, 1.6, 2.4], [7.4, 1.1, 2.0]]:
		lp.cone("foliage", pos + Vector3(0, c[0] * s, 0), c[1] * s, c[2] * s, 8, Color(0.42, 0.42, 0.42), Color.WHITE, 2.0)
	var cs := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 0.35 * s
	shape.height = 3.0
	cs.shape = shape
	cs.position = pos + Vector3(0, 1.5, 0)
	body.add_child(cs)


func _poles(lp: LowPoly) -> void:
	var z := -3.1
	for x in [-2.0, 34.0]:
		lp.cylinder("bark", Vector3(x, 0, z), 0.14, 8.5, 6, Color(0.55, 0.55, 0.55), Color.WHITE, 2.0)
		lp.box("bark", Vector3(x, 7.9, z), Vector3(0.12, 0.12, 2.0), 1.0)
	for dz in [-0.8, 0.0, 0.8]:
		lp.box("wire", Vector3(16.0, 7.85, z + dz), Vector3(36.0, 0.03, 0.03), 8.0, Color.WHITE, Color.WHITE, 20.0)
	# street lamp
	lp.cylinder("pole", Vector3(5.8, 0, -3.2), 0.1, 6.4, 6, Color(0.6, 0.6, 0.6), Color.WHITE, 2.0)
	lp.box("pole", Vector3(5.8, 6.4, -2.55), Vector3(0.1, 0.1, 1.4), 1.0)
	lp.box("lamp", Vector3(5.8, 6.3, -1.9), Vector3(0.55, 0.18, 0.35), 1.0)


# ------------------------------------------------------------------ walker

func _spawn_walker() -> void:
	walker = CharacterBody3D.new()
	walker.set_script(DEV_WALKER)
	walker.name = "Walker"
	walker.set("capture_mouse", capture_mouse)
	add_child(walker)
	set_camera(Vector3(-16.0, 1.6, 3.5), Vector3(0.0, 2.2, -9.0))
