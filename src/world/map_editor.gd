class_name MapEditor
extends Control

## In-game map editor. Tab "Obiekty": the props (MapProps): select, move, rotate, scale, duplicate, delete objects,
## draw paths / fences / hedges point by point, undo, save to data/map/props.json.  F2 opens / closes it
## (LiniaView). Tab "Budynki" (F3): houses, see BuildingEditor. It is a tool for the author, not a part of the game.
##
## Mouse: LEFT click selects / places / adds a polyline point; LEFT drag moves the selection (or a polyline
## point); RIGHT hold = look around; WASD + Space / E up + Ctrl / Q down = fly; Shift = faster; wheel = rotate.
## Keys: R / T rotate, [ and ] smaller / bigger (path: narrower / wider), X or Del delete (a selected polyline
## point, else the whole object), C duplicate, I insert a polyline point, Enter finish a line, Backspace remove
## the last drawn point, Esc cancel / deselect, U or Ctrl+Z undo, F5 save.

const SNAP_ROT_DEG := 15.0
const HANDLE_PX := 9.0
const MAX_UNDO := 60

var view: Control
var world: Node
var props: MapProps
var active := false
var armed := ""
var draft: Array = []
var draft_smooth := false
var sel := -1
var sel_pt := -1
var dirty := false

var _drag := false
var _drag_moved := false
var _drag_ground := Vector2.ZERO
var _undo: Array = []
var _panel: PanelContainer
var _status: Label
var _group := ButtonGroup.new()
var _buttons := {}
var _im: ImmediateMesh
var _overlay: MeshInstance3D
var _was_flying := false
## "props" (trees, paths, fences) or "buildings" (BuildingEditor); F3 switches.
var mode := "props"
var buildings: BuildingSet
var bed: BuildingEditor
var _props_box: VBoxContainer
var _bld_box: VBoxContainer
var _mode_buttons := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	buildings = world.get("buildings")
	if buildings != null:
		bed = BuildingEditor.new(self, buildings)
	_build_panel()
	_im = ImmediateMesh.new()
	_overlay = MeshInstance3D.new()
	_overlay.mesh = _im
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.no_depth_test = true
	_overlay.material_override = mat
	_overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(_overlay)
	set_active(false)


# ------------------------------------------------------------------ panel

func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(8, 40)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.07, 0.82)
	sb.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	_panel.add_child(box)
	box.add_child(_label("EDYTOR MAPY  (F2 zamyka)", 15, Color(1, 0.85, 0.4)))
	var tabs := HBoxContainer.new()
	box.add_child(tabs)
	var tab_group := ButtonGroup.new()
	for spec in [["Obiekty", "props"], ["Budynki", "buildings"]]:
		var tb := Button.new()
		tb.text = spec[0]
		tb.toggle_mode = true
		tb.button_group = tab_group
		tb.focus_mode = Control.FOCUS_NONE
		tb.button_pressed = spec[1] == "props"
		tb.disabled = spec[1] == "buildings" and bed == null
		tb.pressed.connect(set_mode.bind(String(spec[1])))
		tabs.add_child(tb)
		_mode_buttons[spec[1]] = tb
	tabs.add_child(_label("  F3 przełącza", 11, Color(0.75, 0.75, 0.75)))
	var outer := box
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	outer.add_child(box)
	_props_box = box
	_add_button(box, "", "Wybierz / przesuwaj")
	for sec in [["point", "Obiekty"], ["line", "Linie (klikaj punkty, Enter kończy)"],
			["area", "Place (klikaj rogi, Enter zamyka wielokąt)"]]:
		box.add_child(_label(String(sec[1]), 12, Color(0.7, 0.8, 0.9)))
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 3)
		grid.add_theme_constant_override("v_separation", 2)
		box.add_child(grid)
		for t in MapProps.TYPES:
			if MapProps.kind_of(t) == String(sec[0]):
				_add_button(grid, t, String(MapProps.TYPES[t]["label"]))
	var row := HBoxContainer.new()
	box.add_child(row)
	for spec in [["Zapisz F5", "save"], ["Cofnij U", "undo"], ["Usuń X", "delete"], ["Kopiuj C", "dup"], ["Krzywa K", "smooth"]]:
		var b := Button.new()
		b.text = spec[0]
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 12)
		b.pressed.connect(_on_action.bind(String(spec[1])))
		row.add_child(b)
	_bld_box = VBoxContainer.new()
	_bld_box.add_theme_constant_override("separation", 3)
	_bld_box.visible = false
	outer.add_child(_bld_box)
	if bed != null:
		bed.build_panel(_bld_box)
	_status = _label("", 12, Color(0.85, 0.95, 0.85))
	_status.custom_minimum_size = Vector2(320, 0)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outer.add_child(_status)
	box.add_child(_label("PPM trzymaj = rozglądanie, WASD lot, kółko/R/T obrót, [ ] rozmiar,\nPgUp/PgDn w górę/w dół (Shift = 0,5 m), Home = na ziemię,\nK krzywa/proste, I wstaw punkt / róg, Enter koniec, Esc anuluj,\nTab = następny obiekt pod kursorem", 11, Color(0.75, 0.75, 0.75)))


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _add_button(parent: Control, type: String, text: String) -> void:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.button_group = _group
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 12)
	b.custom_minimum_size = Vector2(158, 0)
	b.pressed.connect(_on_arm.bind(type))
	parent.add_child(b)
	_buttons[type] = b
	if type == "":
		b.button_pressed = true


func _on_arm(type: String) -> void:
	arm(type)


func _on_action(what: String) -> void:
	match what:
		"save": save()
		"undo": undo()
		"delete": delete_selected()
		"dup": duplicate_selected()
		"smooth": toggle_smooth()


# ------------------------------------------------------------------ state

func set_active(on: bool) -> void:
	active = on
	_panel.visible = on
	_overlay.visible = on
	var walker = world.get("walker")
	if walker == null:
		return
	if on:
		_was_flying = bool(walker.get("fly"))
		walker.call("set_fly", true)
		walker.set("editor_mode", true)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if bed != null:
			bed.on_leave()
		walker.set("editor_mode", false)
		if not _was_flying:
			walker.call("set_fly", false)
		draft.clear()
		armed = ""
		_drag = false
		if bool(view.get("capture_mouse")):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_update_status()


func arm(type: String) -> void:
	armed = type
	draft.clear()
	sel_pt = -1
	if _buttons.has(type):
		(_buttons[type] as Button).button_pressed = true
	_update_status()


func set_mode(m: String) -> void:
	if m == "buildings" and bed == null:
		return
	if m == mode:
		return
	mode = m
	if m == "buildings":
		draft.clear()
		arm("")
		select(-1)
	elif bed != null:
		bed.on_leave()
	_props_box.visible = m == "props"
	_bld_box.visible = m == "buildings"
	_panel.reset_size()      # shrink to the shown tab
	(_mode_buttons[m] as Button).button_pressed = true
	_update_status()


func _push_undo() -> void:
	_undo.append([props.snapshot(), buildings.snapshot() if buildings != null else ""])
	if _undo.size() > MAX_UNDO:
		_undo.pop_front()
	dirty = true


func undo() -> void:
	if _undo.is_empty():
		return
	var snap: Array = _undo.pop_back()
	props.restore(snap[0])
	if buildings != null and snap[1] != "":
		buildings.restore(snap[1])
		if bed != null:
			bed.after_undo()
	if props.get_item(sel).is_empty():
		sel = -1
		sel_pt = -1
	_update_status("Cofnięto.")


func save() -> bool:
	var ok := props.save_file()
	if buildings != null:
		ok = buildings.save_file() and ok
	if ok:
		dirty = false
	_update_status("Zapisano obiekty (%d) i budynki (%s)." % [props.items.size(), buildings.path if buildings != null else "-"] if ok else "BŁĄD zapisu!")
	return ok


func _update_status(msg: String = "") -> void:
	if _status == null:
		return
	var text := msg
	if text == "" and mode == "buildings" and bed != null:
		text = bed.status()
	if text == "":
		if draft.size() > 0:
			text = "Rysowanie: %d pkt (%s, K przełącza). Klikaj dalej, Enter %s, Backspace cofa punkt." % [draft.size(),
				"krzywa" if draft_smooth else "proste odcinki", "zamyka plac" if MapProps.kind_of(armed) == "area" else "kończy"]
		elif armed != "":
			text = "Kliknij na ziemi, aby postawić: %s.%s" % [String(MapProps.TYPES[armed]["label"]),
				"  (K = krzywa, teraz %s)" % ("włączona" if draft_smooth else "wyłączona") if _is_drawn(armed) else ""]
		elif sel >= 0:
			var it := props.get_item(sel)
			if not it.is_empty():
				var label := String(MapProps.TYPES.get(String(it["type"]), {}).get("label", it["type"]))
				if it.has("pts") and MapProps.is_area(String(it["type"])):
					text = "Zaznaczono: %s (%d rogów, %s, pow. %.0f m²)%s\nPrzeciągnij róg, I = nowy róg, X = usuń róg, [ ] = mniejszy/większy" % [label,
						(it["pts"] as Array).size(), "krzywa" if bool(it.get("smooth", false)) else "proste boki",
						absf(_poly_area(MapProps.area_outline(it))), "  róg %d" % (sel_pt + 1) if sel_pt >= 0 else ""]
				elif it.has("pts"):
					text = "Zaznaczono: %s (%d pkt, %s, szer. %.1f m, wysokość %.2f m)%s" % [label, (it["pts"] as Array).size(),
						"krzywa" if bool(it.get("smooth", false)) else "proste odcinki", float(it.get("w", 0.0)), float(it.get("y", 0.0)),
						"  punkt %d" % (sel_pt + 1) if sel_pt >= 0 else ""]
				else:
					text = "Zaznaczono: %s  (%.1f, %.1f)  wysokość %.2f m  obrót %d°  rozmiar %.2f" % [label, float(it["x"]), float(it["z"]),
						float(it.get("y", 0.0)), int(round(rad_to_deg(float(it["yaw"])))) % 360, float(it.get("s", 1.0))]
		else:
			text = "Nic nie zaznaczono. Kliknij obiekt albo wybierz coś z listy."
	if dirty:
		text += "\n(niezapisane zmiany: F5)"
	_status.text = text


# ------------------------------------------------------------------ picking

func _camera() -> Camera3D:
	return world.get("walker").call("get_camera")


func _vp_mouse() -> Vector2:
	var cont := view.get_node("View") as SubViewportContainer
	return cont.get_local_mouse_position() / float(cont.stretch_shrink)


func _ray_from_mouse() -> Array:
	var cam := _camera()
	var p := _vp_mouse()
	return [cam.project_ray_origin(p), cam.project_ray_normal(p)]


## Intersection of a ray with the horizontal plane at height `h` (the terrain is flat).
func ground_hit(origin: Vector3, dir: Vector3, h: float = 0.0) -> Variant:
	if absf(dir.y) < 0.0001:
		return null
	var t := (h - origin.y) / dir.y
	if t < 0.0 or t > 400.0:
		return null
	return Vector2(origin.x + dir.x * t, origin.z + dir.z * t)


## Lines and areas are drawn point by point; everything else is placed with one click.
static func _is_drawn(type: String) -> bool:
	return type != "" and MapProps.kind_of(type) != "point"


## Signed area of a polygon given as [[x, z], ...].
static func _poly_area(pts: Array) -> float:
	var a := 0.0
	for i in range(pts.size()):
		var j := (i + 1) % pts.size()
		a += float(pts[i][0]) * float(pts[j][1]) - float(pts[j][0]) * float(pts[i][1])
	return a * 0.5


static func dist_to_polyline(p: Vector2, pts: Array) -> float:
	var best := 1e9
	for i in range(pts.size() - 1):
		var a := Vector2(pts[i][0], pts[i][1])
		var b := Vector2(pts[i + 1][0], pts[i + 1][1])
		var cp := Geometry2D.get_closest_point_to_segment(p, a, b)
		best = minf(best, p.distance_to(cp))
	return best


## Returns the id of the prop hit by this ray (-1 = none): the best of pick_candidates().
func pick_ray(origin: Vector3, dir: Vector3) -> int:
	var c := pick_candidates(origin, dir)
	return -1 if c.is_empty() else int(c[0])


## All props under this ray, best first: exact collision hits (trunks, seats, fence walls) by distance, then the
## coarse click boxes (tree crowns etc.) smallest first, then paths / hedges by how close the ground point is to
## their centre line. A big crown box no longer hides a bench, and a path under an object never wins over it.
func pick_candidates(origin: Vector3, dir: Vector3) -> Array:
	var space: PhysicsDirectSpaceState3D = (world as Node3D).get_world_3d().direct_space_state
	var precise: Array = []     # [dist, id]
	var boxes: Array = []       # [volume, id]
	var exclude: Array[RID] = []
	var wall_dist := 1e9
	for _i in range(16):
		var q := PhysicsRayQueryParameters3D.create(origin, origin + dir * 300.0)
		q.exclude = exclude
		var hit: Dictionary = space.intersect_ray(q)
		if hit.is_empty():
			break
		var col: Object = hit["collider"]
		var pos: Vector3 = hit["position"]
		if col != null and col.has_meta("prop_id"):
			var id := int(col.get_meta("prop_id"))
			var body := col as CollisionObject3D
			if body != null and (body.collision_layer & 1) == 0:
				var vol := 1e9
				var shp := (body.get_child(0) as CollisionShape3D).shape if body.get_child_count() > 0 else null
				if shp is BoxShape3D:
					var sz: Vector3 = (shp as BoxShape3D).size
					vol = sz.x * sz.y * sz.z
				boxes.append([vol, id])
			else:
				precise.append([origin.distance_to(pos), id])
			exclude.append(hit["rid"])
			continue
		if pos.y > 0.4:
			wall_dist = origin.distance_to(pos)
		break
	precise.sort_custom(func(a, b): return a[0] < b[0])
	boxes.sort_custom(func(a, b): return a[0] < b[0])
	var lines: Array = []       # [footprint distance, id]; areas after all lines, the smallest first
	var g = ground_hit(origin, dir)
	if g != null and origin.distance_to(Vector3(g.x, 0.0, g.y)) <= wall_dist:
		for it in props.items:
			var type := String(it["type"])
			if MapProps.is_area(type):
				var outline := MapProps.area_outline(it)
				var poly := PackedVector2Array()
				for p in outline:
					poly.append(Vector2(p[0], p[1]))
				if poly.size() >= 3 and Geometry2D.is_point_in_polygon(g, poly):
					lines.append([100.0 + absf(_poly_area(outline)), int(it["id"])])
				continue
			if not (MapProps.is_path(type) or type == "hedge"):
				continue
			var reach := 0.9 if type == "hedge" else float(it.get("w", 1.8)) * 0.5 + 0.15
			var d := dist_to_polyline(g, MapProps.sample(it["pts"], bool(it.get("smooth", false)), 0.8))
			if d <= reach:
				lines.append([d, int(it["id"])])
	lines.sort_custom(func(a, b): return a[0] < b[0])
	var out: Array = []
	for group in [precise, boxes, lines]:
		for e in group:
			if not out.has(int(e[1])):
				out.append(int(e[1]))
	return out


## Tab: the next object under the mouse after the current selection (for objects that stand on / inside others).
func cycle_pick() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
	var r := _ray_from_mouse()
	var c := pick_candidates(r[0], r[1])
	if c.is_empty():
		return
	var i := c.find(sel)
	select(int(c[(i + 1) % c.size()]))
	_update_status("Następny obiekt pod kursorem (%d/%d)." % [(i + 1) % c.size() + 1, c.size()])


## Index of the polyline point of the selected line under the mouse (-1 = none).
func pick_handle() -> int:
	var it := props.get_item(sel)
	if it.is_empty() or not it.has("pts"):
		return -1
	var cam := _camera()
	var mp := _vp_mouse()
	var best := -1
	var best_d := HANDLE_PX
	for i in range((it["pts"] as Array).size()):
		var w := Vector3(it["pts"][i][0], float(it.get("y", 0.0)), it["pts"][i][1])
		if cam.is_position_behind(w):
			continue
		var d := cam.unproject_position(w).distance_to(mp)
		if d < best_d:
			best_d = d
			best = i
	return best


# ------------------------------------------------------------------ editing actions

func select(id: int, pt: int = -1) -> void:
	sel = id
	sel_pt = pt
	_update_status()


func place_point(type: String, g: Vector2) -> int:
	_push_undo()
	var last_yaw := 0.0
	var id := props.add_point(type, snappedf(g.x, 0.05), snappedf(g.y, 0.05), last_yaw, 1.0)
	select(id)
	settle(id)
	return id


## Height of the top of whatever solid thing is under (x, z), ignoring prop `skip` (0 = only the ground).
func surface_y(g: Vector2, skip: int = -1) -> float:
	var space: PhysicsDirectSpaceState3D = (world as Node3D).get_world_3d().direct_space_state
	var exclude: Array[RID] = []
	for _i in range(8):
		var q := PhysicsRayQueryParameters3D.create(Vector3(g.x, 6.0, g.y), Vector3(g.x, -1.0, g.y))
		q.collision_mask = 1
		q.exclude = exclude
		var hit: Dictionary = space.intersect_ray(q)
		if hit.is_empty():
			return 0.0
		var col: Object = hit["collider"]
		if col != null and col.has_meta("prop_id") and int(col.get_meta("prop_id")) == skip:
			exclude.append(hit["rid"])
			continue
		return maxf(float((hit["position"] as Vector3).y), 0.0)
	return 0.0


## Candles go onto the slab / kerb under them (MapProps.SITS_ON_TOP); other objects keep their height.
func settle(id: int) -> void:
	var it := props.get_item(id)
	if it.is_empty() or not MapProps.SITS_ON_TOP.has(String(it["type"])):
		return
	it["y"] = snappedf(surface_y(Vector2(float(it["x"]), float(it["z"])), id), 0.01)
	props.update_transform(id)


func add_draft_point(g: Vector2) -> void:
	draft.append([snappedf(g.x, 0.05), snappedf(g.y, 0.05)])
	_update_status()


func finish_draft() -> int:
	var need := 3 if MapProps.kind_of(armed) == "area" else 2
	if draft.size() < need:
		draft.clear()
		_update_status("Plac potrzebuje co najmniej 3 rogów." if need == 3 else "Linia potrzebuje co najmniej 2 punktów.")
		return -1
	_push_undo()
	var id := props.add_line(armed, draft.duplicate(true), -1.0, draft_smooth)
	draft.clear()
	select(id)
	return id


## Straight <-> smooth curve through the control points (the selected line, or the line being drawn).
func toggle_smooth() -> void:
	if draft.size() > 0 or _is_drawn(armed):
		draft_smooth = not draft_smooth
		_update_status("Krzywa: %s." % ("włączona" if draft_smooth else "wyłączona"))
		return
	var it := props.get_item(sel)
	if it.is_empty() or not it.has("pts"):
		return
	_push_undo()
	it["smooth"] = not bool(it.get("smooth", false))
	props.rebuild_item(sel)
	_update_status()


func delete_selected() -> void:
	var it := props.get_item(sel)
	if it.is_empty():
		return
	_push_undo()
	var min_pts := 3 if MapProps.is_area(String(it["type"])) else 2
	if sel_pt >= 0 and it.has("pts") and (it["pts"] as Array).size() > min_pts:
		(it["pts"] as Array).remove_at(sel_pt)
		sel_pt = -1
		props.rebuild_item(sel)
	else:
		props.remove_item(sel)
		sel = -1
		sel_pt = -1
	_update_status()


func duplicate_selected() -> void:
	var it := props.get_item(sel)
	if it.is_empty():
		return
	_push_undo()
	var id: int
	if it.has("pts"):
		var pts: Array = []
		for p in it["pts"]:
			pts.append([float(p[0]) + 2.0, float(p[1]) + 2.0])
		id = props.add_line(String(it["type"]), pts, float(it.get("w", 0.0)), bool(it.get("smooth", false)))
	else:
		id = props.add_point(String(it["type"]), float(it["x"]) + 2.0, float(it["z"]) + 2.0, float(it["yaw"]), float(it.get("s", 1.0)))
	if it.has("y"):
		props.get_item(id)["y"] = it["y"]
		props.update_transform(id)
	select(id)


## Raises (+) or lowers (-) the selection by `dy` metres (only the height offset changes).
func move_selected_y(dy: float) -> void:
	var it := props.get_item(sel)
	if it.is_empty():
		return
	_push_undo()
	it["y"] = snappedf(float(it.get("y", 0.0)) + dy, 0.01)
	props.update_transform(sel)
	_update_status()


func reset_selected_y() -> void:
	var it := props.get_item(sel)
	if it.is_empty():
		return
	_push_undo()
	it["y"] = 0.0
	props.update_transform(sel)
	_update_status()


func rotate_selected(deg: float) -> void:
	var it := props.get_item(sel)
	if it.is_empty():
		return
	_push_undo()
	var a := deg_to_rad(deg)
	if it.has("pts"):
		var c := Vector2.ZERO
		for p in it["pts"]:
			c += Vector2(p[0], p[1])
		c /= float((it["pts"] as Array).size())
		for p in it["pts"]:
			var v := (Vector2(p[0], p[1]) - c).rotated(-a)
			p[0] = c.x + v.x
			p[1] = c.y + v.y
		props.rebuild_item(sel)
	else:
		it["yaw"] = fposmod(float(it["yaw"]) + a, TAU)
		props.update_transform(sel)
	_update_status()


func scale_selected(factor: float) -> void:
	var it := props.get_item(sel)
	if it.is_empty():
		return
	_push_undo()
	if it.has("pts"):
		if MapProps.is_path(String(it["type"])):
			it["w"] = clampf(float(it["w"]) * factor, 0.3, 40.0)
			props.rebuild_item(sel)
		elif MapProps.is_area(String(it["type"])):
			var c := Vector2.ZERO
			for p in it["pts"]:
				c += Vector2(p[0], p[1])
			c /= float((it["pts"] as Array).size())
			for p in it["pts"]:
				var v := (Vector2(p[0], p[1]) - c) * factor
				p[0] = snappedf(c.x + v.x, 0.05)
				p[1] = snappedf(c.y + v.y, 0.05)
			props.rebuild_item(sel)
	else:
		it["s"] = clampf(float(it.get("s", 1.0)) * factor, 0.3, 4.0)
		props.rebuild_item(sel)
	_update_status()


func insert_point_at(g: Vector2) -> void:
	var it := props.get_item(sel)
	if it.is_empty() or not it.has("pts"):
		return
	var pts: Array = it["pts"]
	var best_i := 0
	var best_d := 1e9
	var best_p := g
	var closed := MapProps.is_area(String(it["type"]))
	for i in range(pts.size() - (0 if closed else 1)):
		var j := (i + 1) % pts.size()
		var cp := Geometry2D.get_closest_point_to_segment(g, Vector2(pts[i][0], pts[i][1]), Vector2(pts[j][0], pts[j][1]))
		if g.distance_to(cp) < best_d:
			best_d = g.distance_to(cp)
			best_i = i
			best_p = cp
	_push_undo()
	pts.insert(best_i + 1, [snappedf(best_p.x, 0.05), snappedf(best_p.y, 0.05)])
	sel_pt = best_i + 1
	props.rebuild_item(sel)
	_update_status()


# ------------------------------------------------------------------ input

func _over_panel() -> bool:
	return _panel.visible and _panel.get_global_rect().has_point(get_global_mouse_position())


func _input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if mb.pressed else Input.MOUSE_MODE_VISIBLE
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not _over_panel():
				if mode == "buildings":
					bed.left_press()
				else:
					_left_press()
			elif not mb.pressed:
				if mode == "buildings":
					bed.left_release()
				else:
					_left_release()
		elif mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			if mode == "buildings":
				if bed.sel != -1 and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not _over_panel():
					bed.wheel(mb.button_index == MOUSE_BUTTON_WHEEL_UP)
			elif sel >= 0 and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not _over_panel():
				var step := 45.0 if Input.is_key_pressed(KEY_SHIFT) else 5.0
				rotate_selected(step if mb.button_index == MOUSE_BUTTON_WHEEL_UP else -step)
	elif event is InputEventMouseMotion:
		if mode == "buildings":
			bed.drag_motion()
		elif _drag:
			_drag_motion()
	elif event is InputEventKey and event.pressed and not event.echo:
		_key(event as InputEventKey)


func _key(e: InputEventKey) -> void:
	match e.keycode:
		KEY_F3:
			set_mode("props" if mode == "buildings" else "buildings")
			return
		KEY_F5:
			save()
			return
		KEY_U:
			undo()
			return
		KEY_Z:
			if e.ctrl_pressed:
				undo()
			return
	if mode == "buildings":
		bed.key(e)
		_update_status()
		return
	match e.keycode:
		KEY_R: rotate_selected(SNAP_ROT_DEG)
		KEY_T: rotate_selected(-SNAP_ROT_DEG)
		KEY_BRACKETLEFT: scale_selected(1.0 / 1.15)
		KEY_BRACKETRIGHT: scale_selected(1.15)
		KEY_DELETE, KEY_X: delete_selected()
		KEY_C: duplicate_selected()
		KEY_K: toggle_smooth()
		KEY_PAGEUP: move_selected_y(0.5 if e.shift_pressed else 0.1)
		KEY_PAGEDOWN: move_selected_y(-0.5 if e.shift_pressed else -0.1)
		KEY_HOME: reset_selected_y()
		KEY_I:
			var r := _ray_from_mouse()
			var g = ground_hit(r[0], r[1])
			if g != null:
				insert_point_at(g)
		KEY_ENTER, KEY_KP_ENTER:
			if draft.size() > 0:
				finish_draft()
		KEY_BACKSPACE:
			if draft.size() > 0:
				draft.pop_back()
				_update_status()
		KEY_ESCAPE:
			_drag = false
			if draft.size() > 0:
				draft.clear()
			elif armed != "":
				arm("")
			else:
				select(-1)
			_update_status()
		KEY_TAB: cycle_pick()


func _left_press() -> void:
	var r := _ray_from_mouse()
	var g = ground_hit(r[0], r[1])
	if armed != "":
		if g == null:
			return
		if _is_drawn(armed):
			add_draft_point(g)
		else:
			place_point(armed, g)
			_start_drag(g)
		return
	# select mode: a polyline handle first, then objects
	var h := pick_handle()
	if h >= 0:
		sel_pt = h
		_push_undo()
		var gh = ground_hit(r[0], r[1], _sel_y())
		_start_drag(gh if gh != null else Vector2.ZERO)
		_update_status()
		return
	var id := pick_ray(r[0], r[1])
	if id >= 0:
		select(id)
		_push_undo()
		var gs = ground_hit(r[0], r[1], _sel_y())
		_start_drag(gs if gs != null else Vector2.ZERO)
	else:
		select(-1)


## Height offset of the selection (dragging happens on the horizontal plane at this height).
func _sel_y() -> float:
	return float(props.get_item(sel).get("y", 0.0))


func _start_drag(g: Vector2) -> void:
	_drag = true
	_drag_moved = false
	_drag_ground = g


func _drag_motion() -> void:
	if sel < 0:
		return
	var r := _ray_from_mouse()
	var g = ground_hit(r[0], r[1], _sel_y())
	if g == null:
		return
	var delta: Vector2 = g - _drag_ground
	if delta.length() < 0.01:
		return
	_drag_moved = true
	_drag_ground = g
	var it := props.get_item(sel)
	if it.is_empty():
		return
	if it.has("pts"):
		if sel_pt >= 0:
			it["pts"][sel_pt][0] = snappedf(float(it["pts"][sel_pt][0]) + delta.x, 0.05)
			it["pts"][sel_pt][1] = snappedf(float(it["pts"][sel_pt][1]) + delta.y, 0.05)
		else:
			for p in it["pts"]:
				p[0] = float(p[0]) + delta.x
				p[1] = float(p[1]) + delta.y
		props.rebuild_item(sel)
	else:
		it["x"] = float(it["x"]) + delta.x
		it["z"] = float(it["z"]) + delta.y
		props.update_transform(sel)
	dirty = true


func _left_release() -> void:
	if _drag and not _drag_moved and _undo.size() > 0 and armed == "":
		# a plain click moved nothing: drop the undo snapshot taken on press
		_undo.pop_back()
	elif _drag and _drag_moved and sel >= 0:
		settle(sel)
	_drag = false
	_update_status()


# ------------------------------------------------------------------ overlay

func _process(_delta: float) -> void:
	if not active or _im == null:
		return
	_im.clear_surfaces()
	_im.surface_begin(Mesh.PRIMITIVE_LINES)
	if mode == "buildings":
		bed.draw()
	var it := props.get_item(sel)
	if not it.is_empty():
		if it.has("pts"):
			var oy := float(it.get("y", 0.0))
			if MapProps.is_area(String(it["type"])):
				var loop := MapProps.area_outline(it).duplicate()
				loop.append(loop[0])
				_draw_polyline(loop, Color(0.2, 0.9, 1.0), 0.25 + oy)
			else:
				_draw_polyline(MapProps.sample(it["pts"], bool(it.get("smooth", false)), 0.8), Color(0.2, 0.9, 1.0), 0.25 + oy)
			for i in range((it["pts"] as Array).size()):
				_draw_cross(Vector3(it["pts"][i][0], 0.3 + oy, it["pts"][i][1]), 0.45, Color(1, 0.2, 0.2) if i == sel_pt else Color.WHITE)
		elif props.nodes.has(sel):
			_draw_box(_node_aabb(props.nodes[sel]), Color(1.0, 0.9, 0.2))
	if draft.size() > 0:
		var pts := draft.duplicate()
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			var r := _ray_from_mouse()
			var g = ground_hit(r[0], r[1])
			if g != null:
				pts.append([g.x, g.y])
		if MapProps.kind_of(armed) == "area" and pts.size() >= 3:
			var loop := MapProps.sample_closed(pts, draft_smooth, 0.8).duplicate()
			loop.append(loop[0])
			_draw_polyline(loop, Color(1.0, 0.6, 0.1), 0.25)
		else:
			_draw_polyline(MapProps.sample(pts, draft_smooth, 0.8), Color(1.0, 0.6, 0.1), 0.25)
		for p in draft:
			_draw_cross(Vector3(p[0], 0.3, p[1]), 0.45, Color(1.0, 0.6, 0.1))
	if armed != "" and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not _over_panel():
		var r2 := _ray_from_mouse()
		var g2 = ground_hit(r2[0], r2[1])
		if g2 != null:
			_draw_cross(Vector3(g2.x, 0.2, g2.y), 0.8, Color(0.3, 1.0, 0.3))
	# surface_end needs at least one vertex: a degenerate line keeps it valid
	_im.surface_add_vertex(Vector3.ZERO)
	_im.surface_add_vertex(Vector3.ZERO)
	_im.surface_end()


func _line(a: Vector3, b: Vector3, c: Color) -> void:
	_im.surface_set_color(c)
	_im.surface_add_vertex(a)
	_im.surface_set_color(c)
	_im.surface_add_vertex(b)


func _draw_polyline(pts: Array, c: Color, y: float) -> void:
	for i in range(pts.size() - 1):
		_line(Vector3(pts[i][0], y, pts[i][1]), Vector3(pts[i + 1][0], y, pts[i + 1][1]), c)


func _draw_cross(p: Vector3, r: float, c: Color) -> void:
	_line(p - Vector3(r, 0, 0), p + Vector3(r, 0, 0), c)
	_line(p - Vector3(0, 0, r), p + Vector3(0, 0, r), c)
	_line(p, p + Vector3(0, r * 1.6, 0), c)


func _draw_box(b: AABB, c: Color) -> void:
	var p := b.position
	var s := b.size
	for i in range(4):
		var x0 := p.x + (s.x if (i == 1 or i == 2) else 0.0)
		var z0 := p.z + (s.z if (i == 2 or i == 3) else 0.0)
		var j := (i + 1) % 4
		var x1 := p.x + (s.x if (j == 1 or j == 2) else 0.0)
		var z1 := p.z + (s.z if (j == 2 or j == 3) else 0.0)
		_line(Vector3(x0, p.y, z0), Vector3(x1, p.y, z1), c)
		_line(Vector3(x0, p.y + s.y, z0), Vector3(x1, p.y + s.y, z1), c)
		_line(Vector3(x0, p.y, z0), Vector3(x0, p.y + s.y, z0), c)


static func _node_aabb(n: Node) -> AABB:
	var out := AABB()
	var first := true
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		if mi.mesh == null:
			continue
		var b := mi.global_transform * mi.get_aabb()
		out = b if first else out.merge(b)
		first = false
	return out
