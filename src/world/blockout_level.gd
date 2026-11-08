extends PS2WorldBase
class_name BlockoutLevel

## The centre of Linia built from OSM footprints (data/blockout/centrum.json) in the PS2 look.
##
## JSON coordinates are metres from the church: x = east, y = north. In Godot they become
## Vector3(east, up, -north), so -Z is north. Houses come from BuildingSet: an archetype per building
## (data/buildings/archetypes.json, chosen from the OSM size / storeys or by the author in the F2 editor),
## the author's changes in data/blockout/overrides.json. Terrain is flat (no elevation data yet).
## Entrances do not exist yet: every building is solid.

const UP := Vector3.UP
const STOREY := 2.8
const WALL_TILE := 3.0
const ROOF_TILE := 2.0
const GABLE_FILL_MIN := 0.86              # footprint area / bounding rectangle area needed for a gable roof
const GROUND_CELL := 8.0
# The church nave runs along this heading (degrees from east, counter-clockwise, in the OSM east/north frame);
# its tower and porch are at the +s end. Found from the footprint and checked against the photos.
const CHURCH_HEADING_DEG := 115.0
const PROPS_PATH := "res://data/map/props.json"

const DIRT := Color(0.44, 0.42, 0.38)     # baked grime / ambient occlusion at the foot of walls
const WALL_TINTS := [
	Color(1.0, 1.0, 1.0), Color(1.0, 0.96, 0.86), Color(0.90, 0.94, 0.92), Color(1.0, 0.91, 0.78),
	Color(0.88, 0.90, 0.95), Color(0.96, 0.88, 0.82), Color(0.84, 0.86, 0.80),
]
const PAVED := ["primary", "secondary", "tertiary", "unclassified", "residential", "living_street", "service"]
# Roads are separate flat layers; wider/more important ones lie lower so that crossings do not z-fight.
const ROAD_Y := {"track": 0.05, "path": 0.06, "footway": 0.06, "cycleway": 0.06, "bridleway": 0.06, "service": 0.08,
	"unclassified": 0.09, "residential": 0.10, "living_street": 0.10, "tertiary": 0.11, "secondary": 0.12, "primary": 0.13}

@export var data_path := "res://data/blockout/centrum.json"
## The author's building changes (tests point this at a file that does not exist, to get the plain OSM layout).
@export var overrides_path := BuildingSet.OVERRIDES_PATH
@export var spawn_walker := true

var data: Dictionary = {}
var footprints: Array = []          # [{ "id": int, "ring": PackedVector2Array (x, z), "height": float, "kind": String }]
var roof_failures := 0
var gable_roofs := 0
var flat_roofs := 0
var window_count := 0
var spawn_position := Vector3.ZERO
var spawn_yaw := 0.0
var church_position := Vector3.ZERO
var build_ms := 0
var church_center_en := Vector2.ZERO     # (east, north) of the footprint centroid
var props: MapProps
var buildings: BuildingSet
var _church_fp: Dictionary = {}
var _school_fps: Array = []


func _ready() -> void:
	build()


func build() -> void:
	var t0 := Time.get_ticks_msec()
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(data_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("BlockoutLevel: cannot read %s" % data_path)
		return
	data = parsed
	_make_materials()
	_make_environment()
	var lp := LowPoly.new()
	var col_faces := PackedVector3Array()
	_ground(lp)
	_roads(lp)
	_church_and_buildings(lp, col_faces)
	var mi := MeshInstance3D.new()
	mi.name = "Linia"
	mi.mesh = lp.build(materials)
	add_child(mi)
	_colliders(col_faces)
	_make_props()
	var sp: Array = data["spawn"]
	spawn_position = _to3(sp[0], sp[1])
	var to_church := church_position - spawn_position
	spawn_yaw = atan2(-to_church.x, -to_church.z)
	if spawn_walker:
		_spawn_walker()
	set_phase("day")
	build_ms = Time.get_ticks_msec() - t0


## JSON (east, north) -> Godot position.
func _to3(east: float, north: float, y: float = 0.0) -> Vector3:
	return Vector3(east, y, -north)


func point_in_footprint(p: Vector2) -> int:
	if not _church_fp.is_empty() and Geometry2D.is_point_in_polygon(p, _church_fp["ring"]):
		return int(_church_fp["id"])
	for f in _school_fps:
		if Geometry2D.is_point_in_polygon(p, f["ring"]):
			return int(f["id"])
	return buildings.point_in_footprint(p) if buildings != null else -1


## Hand-made buildings outside the BuildingSet (the church and the school's two OSM buildings).
func key_footprint_count() -> int:
	return (0 if _church_fp.is_empty() else 1) + _school_fps.size()


func _make_materials() -> void:
	materials = {
		"ground": PS2Look.make_material("grass"),
		"ground_far": PS2Look.make_material("grass"),
		"road": PS2Look.make_material("asphalt"),
		"dirt": PS2Look.make_material("gravel"),
		"wall": PS2Look.make_material("plaster_cream"),
		"wall2": PS2Look.make_material("plaster_grey"),
		"roof_red": PS2Look.make_material("roof_tiles_red"),
		"roof_brown": PS2Look.make_material("roof_tiles_brown"),
		"roof_flat": PS2Look.make_material("plaster_grey", Color(0.45, 0.45, 0.47)),
		"win": PS2Look.make_material("window_dark"),
		"win_lit": PS2Look.make_material("window_dark"),
		"door": PS2Look.make_material("door_wood"),
		"brick": PS2Look.make_material("brick"),
		"planks": PS2Look.make_material("fence_planks"),
		"b_breeze": PS2Look.make_material("b_breeze"),
		"b_roof_sheet": PS2Look.make_material("b_roof_sheet"),
		"b_garage": PS2Look.make_material("b_garage"),
		"b_shopfront": PS2Look.make_material("b_shopfront"),
		# the church (src/world/church_model.gd)
		"c_plaster": PS2Look.make_material("c_plaster"),
		"c_roof": PS2Look.make_material("c_roof_metal"),
		"c_stone": PS2Look.make_material("c_fieldstone"),
		"c_timber": PS2Look.make_material("c_timber"),
		"c_clock": PS2Look.make_material("c_clock"),
		"c_arch_white": PS2Look.make_material("c_arch_white"),
		"c_arch_louvre": PS2Look.make_material("c_arch_louvre"),
		"c_arch_brown": PS2Look.make_material("c_arch_brown"),
		"c_window_grid": PS2Look.make_material("c_window_grid"),
		"c_door": PS2Look.make_material("c_door_green"),
		"c_cross": PS2Look.make_material("c_cross"),
		"c_belfry": PS2Look.make_material("c_belfry"),
		"c_rail": PS2Look.make_material("c_balustrade"),
		"c_black": PS2Look.make_material("plaster_grey", Color(0.07, 0.07, 0.08)),
		# the church yard (src/world/church_grounds.gd)
		"g_cobble": PS2Look.make_material("g_cobble"),
		"g_picket": PS2Look.make_material("g_picket"),
		"g_conifer": PS2Look.make_material("g_conifer"),
		"g_foliage": PS2Look.make_material("foliage", Color(0.8, 0.9, 0.7)),
		"g_bark": PS2Look.make_material("bark"),
		"g_wood": PS2Look.make_material("c_timber", Color(0.9, 0.8, 0.7)),
		"g_darkwood": PS2Look.make_material("c_timber", Color(0.42, 0.36, 0.32)),
		"g_raywood": PS2Look.make_material("c_timber", Color(0.62, 0.50, 0.40)),
		"g_cobble_red": PS2Look.make_material("g_cobble", Color(1.45, 0.62, 0.50)),
		"g_cobble_grey": PS2Look.make_material("g_cobble", Color(0.76, 0.78, 0.83)),
		# more church yard / village props (tools/art/gen_props_textures.py)
		"p_granite": PS2Look.make_material("p_granite"),
		"p_boulder": PS2Look.make_material("p_boulder"),
		"p_metal": PS2Look.make_material("p_metal"),
		"p_notice": PS2Look.make_material("p_notice"),
		"p_candle": PS2Look.make_material("p_candle"),
		"p_box_hedge": PS2Look.make_material("p_box_hedge"),
		"p_gold": PS2Look.make_material("plaster_grey", Color(0.95, 0.78, 0.40)),
		"p_concrete": PS2Look.make_material("plaster_grey", Color(0.92, 0.92, 0.88)),
		# school yard props (tools/art/gen_yard_textures.py)
		"y_paint": PS2Look.make_material("y_paint"),
		"y_chainlink": PS2Look.make_material("y_chainlink"),
		"y_net": PS2Look.make_material("y_net"),
		"y_flowers": PS2Look.make_material("y_flowers"),
		"y_twigs": PS2Look.make_material("y_twigs"),
		"y_turf": PS2Look.make_material("y_turf"),
		"y_line": PS2Look.make_material("plaster_grey", Color(1.35, 1.35, 1.32)),
		"y_soil": PS2Look.make_material("gravel", Color(0.55, 0.45, 0.38)),
		"y_pole": PS2Look.make_material("plaster_grey", Color(0.74, 0.73, 0.69)),
		"y_steel": PS2Look.make_material("plaster_grey", Color(0.46, 0.47, 0.48)),
		"y_insulator": PS2Look.make_material("plaster_grey", Color(1.1, 1.08, 1.0)),
		# church roofs: green patinated sheet on the nave and the wings, dark grey on the rear and the tower cap
		"c_roof_green": PS2Look.make_material("c_roof_metal", Color(0.70, 0.98, 0.90)),
		"c_roof_dark": PS2Look.make_material("c_roof_metal", Color(0.60, 0.61, 0.64)),
		"c_wood": PS2Look.make_material("c_timber", Color(0.55, 0.40, 0.30)),
		# the school (src/world/school_model.gd, tools/art/gen_school_textures.py)
		"s_beige": PS2Look.make_material("s_plaster", Color(1.10, 0.93, 0.78)),
		"s_orange": PS2Look.make_material("s_plaster", Color(0.98, 0.64, 0.44)),
		"s_plinth": PS2Look.make_material("s_plaster", Color(0.80, 0.52, 0.40)),
		"s_white": PS2Look.make_material("s_plaster", Color(1.08, 1.08, 1.08)),
		"s_grey": PS2Look.make_material("s_plaster", Color(0.78, 0.79, 0.81)),
		"s_roof": PS2Look.make_material("s_sheet", Color(0.66, 0.44, 0.36)),
		"s_roof_wing": PS2Look.make_material("s_sheet", Color(0.48, 0.38, 0.35)),
		"s_clad": PS2Look.make_material("s_sheet", Color(1.10, 0.98, 0.76)),
		"s_fascia": PS2Look.make_material("s_plaster", Color(0.46, 0.32, 0.27)),
		"s_frame": PS2Look.make_material("s_plaster", Color(0.30, 0.25, 0.23)),
		"s_rail": PS2Look.make_material("s_plaster", Color(0.62, 0.32, 0.26)),
		"s_brick": PS2Look.make_material("brick", Color(1.10, 0.82, 0.66)),
		"s_win": PS2Look.make_material("s_window_new"),
		"s_win_old": PS2Look.make_material("s_window_old"),
		"s_glazing": PS2Look.make_material("s_glazing"),
		"s_door": PS2Look.make_material("s_door"),
		"s_door_plain": PS2Look.make_material("s_plaster", Color(0.62, 0.64, 0.66)),
		"s_steps": PS2Look.make_material("brick", Color(1.15, 0.62, 0.52)),
	}


func _on_phase(p: Dictionary) -> void:
	var lit: bool = float(p["window_emission"]) > 0.0
	var m := materials["win_lit"] as ShaderMaterial
	m.set_shader_parameter("albedo_tex", PS2Look.load_texture("window_lit" if lit else "window_dark"))
	m.set_shader_parameter("emission_strength", float(p["window_emission"]))
	# grave candles glow a little by day, clearly at dusk and at night
	(materials["p_candle"] as ShaderMaterial).set_shader_parameter("emission_strength", 0.15 + 0.85 * float(p["window_emission"]))


# ------------------------------------------------------------------ ground and roads

func _ground(lp: LowPoly) -> void:
	var b: Dictionary = data["bounds"]
	var x0 := float(b["xmin"]) - 150.0
	var x1 := float(b["xmax"]) + 150.0
	var z0 := -float(b["ymax"]) - 150.0
	var z1 := -float(b["ymin"]) + 150.0
	# a huge base below everything (no cracks, no void at the horizon) and a finer grid on top
	_grid(lp, "ground_far", -3000.0, 3000.0, -3000.0, 3000.0, -0.3, 6000.0)
	_grid(lp, "ground", x0, x1, z0, z1, 0.0, GROUND_CELL)
	var body := StaticBody3D.new()
	body.name = "Ground"
	var shape := BoxShape3D.new()
	shape.size = Vector3(6000.0, 1.0, 6000.0)
	var cs := CollisionShape3D.new()
	cs.shape = shape
	body.add_child(cs)
	body.position = Vector3(0.0, -0.5, 0.0)
	add_child(body)


func _grid(lp: LowPoly, key: String, x0: float, x1: float, z0: float, z1: float, y: float, cell: float, uv_scale: float = 4.0) -> void:
	var nu := maxi(int(ceil((x1 - x0) / cell)), 1)
	var nv := maxi(int(ceil((z1 - z0) / cell)), 1)
	lp.quad_grid(key, Vector3(x0, y, z1), Vector3(x1, y, z1), Vector3(x1, y, z0), Vector3(x0, y, z0),
		Vector2(x0, z1) / uv_scale, Vector2(x1, z1) / uv_scale, Vector2(x1, z0) / uv_scale, Vector2(x0, z0) / uv_scale,
		Color.WHITE, Color.WHITE, nu, nv)


func _roads(lp: LowPoly) -> void:
	var idx := 0
	for road in data["roads"]:
		var hw := String(road["highway"])
		var key := "road" if PAVED.has(hw) else "dirt"
		var y := float(ROAD_Y.get(hw, 0.12)) + float(idx % 4) * 0.006
		idx += 1
		var half := float(road["width"]) * 0.5
		var width_uv := float(road["width"]) / 4.0
		var pts: Array = road["pts"]
		var dist := 0.0
		for i in range(pts.size() - 1):
			var a := _to3(pts[i][0], pts[i][1], y)
			var b := _to3(pts[i + 1][0], pts[i + 1][1], y)
			var d := b - a
			d.y = 0.0
			var seg_len := d.length()
			if seg_len < 0.05:
				continue
			d /= seg_len
			var s := Vector3(-d.z, 0.0, d.x) * half
			var u0 := dist / 4.0
			var u1 := (dist + seg_len) / 4.0
			dist += seg_len
			# (a+s, b+s, b-s, a-s) is counter-clockwise seen from above: the normal points up
			lp.quad_grid(key, a + s, b + s, b - s, a - s,
				Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, width_uv), Vector2(u0, width_uv))


# ------------------------------------------------------------------ buildings

static func _signed_area(ring: PackedVector2Array) -> float:
	var s := 0.0
	for i in range(ring.size()):
		var a := ring[i]
		var b := ring[(i + 1) % ring.size()]
		s += a.x * b.y - b.x * a.y
	return s * 0.5


## A quad whose front face looks along `out_n`: swaps the left/right corners when the order is the wrong way round.
func _quad_out(lp: LowPoly, key: String, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3,
		uv0: Vector2, uv1: Vector2, uv2: Vector2, uv3: Vector2, c_bottom: Color, c_top: Color, out_n: Vector3) -> void:
	if (p1 - p0).cross(p3 - p0).dot(out_n) < 0.0:
		lp.quad_grid(key, p1, p0, p3, p2, uv1, uv0, uv3, uv2, c_bottom, c_top)
	else:
		lp.quad_grid(key, p0, p1, p2, p3, uv0, uv1, uv2, uv3, c_bottom, c_top)


func _tri_out(lp: LowPoly, key: String, a: Vector3, b: Vector3, c: Vector3, uva: Vector2, uvb: Vector2, uvc: Vector2,
		ca: Color, cb: Color, cc: Color, out_n: Vector3) -> void:
	if (b - a).cross(c - a).dot(out_n) < 0.0:
		lp.tri_flat(key, a, c, b, uva, uvc, uvb, ca, cc, cb)
	else:
		lp.tri_flat(key, a, b, c, uva, uvb, uvc, ca, cb, cc)


func _all_road_points() -> Array:
	var pts: Array = []
	for road in data["roads"]:
		for p in road["pts"]:
			pts.append(Vector2(p[0], -p[1]))
	return pts


## The school's two OSM buildings (the old school and the gym footprint, which also holds the new wing) are one
## hand-made model (SchoolModel) instead of two archetype houses.
const SCHOOL_IDS := [864794699, 864794700]


## The church (and the school) go into the static level mesh; every other building into the editable BuildingSet
## (src/world/building_set.gd, archetypes in data/buildings/archetypes.json, author's changes in
## data/blockout/overrides.json).
func _church_and_buildings(lp: LowPoly, col_faces: PackedVector3Array) -> void:
	var rest: Array = []
	for b in data["buildings"]:
		if int(b["id"]) in SCHOOL_IDS:
			_school_part(col_faces, b)
			continue
		if String(b["kind"]) != "church":
			rest.append(b)
			continue
		var ring := PackedVector2Array()
		for p in b["ring"]:
			ring.append(Vector2(p[0], -p[1]))
		_church(lp, col_faces, ring, b)
		_church_fp = {"id": int(b["id"]), "ring": ring, "height": 9.0, "top": 25.0, "kind": "church", "irregular": false}
		var c := Vector2.ZERO
		for v in ring:
			c += v
		church_position = Vector3(c.x / ring.size(), 0.0, c.y / ring.size())
	buildings = BuildingSet.new()
	buildings.name = "Buildings"
	buildings.materials = materials
	buildings.rebuilt.connect(_refresh_footprints)
	add_child(buildings)
	buildings.setup(rest, _all_road_points(), overrides_path)
	if not _school_fps.is_empty():
		SchoolModel.new(lp).build()
	_refresh_footprints()


func _refresh_footprints() -> void:
	footprints = []
	if not _church_fp.is_empty():
		footprints.append(_church_fp)
	footprints.append_array(_school_fps)
	footprints.append_array(buildings.footprints)
	var st: Dictionary = buildings.stats
	gable_roofs = int(st.get("gable", 0)) + int(st.get("hip", 0)) + 1
	flat_roofs = int(st.get("flat", 0))
	roof_failures = int(st.get("roof_fail", 0))
	window_count = int(st.get("windows", 0))


## One OSM building of the school: collision = its footprint (walls up to the eaves), a footprint for picking and
## the wall test. The visible model is built once for both (SchoolModel).
func _school_part(col_faces: PackedVector3Array, b: Dictionary) -> void:
	var ring := SchoolModel.ring_godot(b["ring"])
	var h := 7.4 if String(b["kind"]) == "school" else 13.0
	for i in range(ring.size()):
		var a := ring[i]
		var c := ring[(i + 1) % ring.size()]
		col_faces.append_array([Vector3(a.x, 0.0, a.y), Vector3(c.x, 0.0, c.y), Vector3(c.x, h, c.y),
			Vector3(a.x, 0.0, a.y), Vector3(c.x, h, c.y), Vector3(a.x, h, a.y)])
	_school_fps.append({"id": int(b["id"]), "ring": ring, "height": h, "top": h + 1.5, "kind": String(b["kind"]),
		"irregular": false})


## The church is a hand-modelled landmark (ChurchModel). Its collision stays the OSM footprint, so the wall test
## keeps guarding it; only the visible shape is replaced.
func _church(lp: LowPoly, col_faces: PackedVector3Array, ring: PackedVector2Array, b: Dictionary) -> void:
	var h := 9.0
	for i in range(ring.size()):
		var a := ring[i]
		var c := ring[(i + 1) % ring.size()]
		var a0 := Vector3(a.x, 0.0, a.y)
		var b0 := Vector3(c.x, 0.0, c.y)
		var a1 := Vector3(a.x, h, a.y)
		var b1 := Vector3(c.x, h, c.y)
		col_faces.append_array([a0, b0, b1, a0, b1, a1])
	var cen := Vector2.ZERO
	for p in b["ring"]:
		cen += Vector2(p[0], p[1])
	cen /= float(ring.size())
	church_center_en = cen
	ChurchModel.new(lp, cen, CHURCH_HEADING_DEG).build()


# ------------------------------------------------------------------ collision and walker

func _colliders(col_faces: PackedVector3Array) -> void:
	# The church walls (other buildings have their own body in BuildingSet). backface_collision matters: without it a wall only blocks from the
	# side its normal faces, and a wrongly wound wall can be walked through.
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(col_faces)
	shape.backface_collision = true
	var cs := CollisionShape3D.new()
	cs.shape = shape
	var body := StaticBody3D.new()
	body.name = "ChurchBody"
	body.add_child(cs)
	add_child(body)


## Editable props (trees, crosses, benches, paths, fences): data/map/props.json, edited in game with F2.
## The first time (no file yet) the layout comes from ChurchGrounds.default_items.
func _make_props() -> void:
	props = MapProps.new()
	props.name = "Props"
	props.materials = materials
	add_child(props)
	var frame := ChurchModel.new(null, church_center_en, CHURCH_HEADING_DEG)
	var defaults := []
	if not FileAccess.file_exists(PROPS_PATH):
		defaults = ChurchGrounds.default_items(frame,
			func(p: Vector3) -> bool: return point_in_footprint(Vector2(p.x, p.z)) != -1)
	props.load_or_default(PROPS_PATH, defaults)


func _spawn_walker() -> void:
	walker = CharacterBody3D.new()
	walker.set_script(DEV_WALKER)
	walker.name = "Walker"
	walker.set("capture_mouse", capture_mouse)
	add_child(walker)
	walker.global_position = spawn_position + Vector3(0.0, 0.1, 0.0)
	walker.rotation.y = spawn_yaw
