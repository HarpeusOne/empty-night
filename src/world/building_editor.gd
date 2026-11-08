class_name BuildingEditor
extends RefCounted

## The "Budynki" tab of the in-game map editor (F2, then F3 or the tab button): select a house, change its type,
## storeys, ridge direction and wall colour, move / rotate / resize it, simplify its footprint to a rectangle,
## hide an OSM building, add new ones. MapEditor owns the panel, undo and saving (F5); this class does the rest.
##
## Mouse: LEFT click selects (also inside the outline of a hidden building), LEFT drag moves, wheel rotates.
## Keys: R / T rotate 15 deg, [ ] smaller / bigger, PgUp / PgDn storeys, , and . previous / next type,
## V ridge direction, B rectangle footprint, N wall colour, C copy, X / Del hide (OSM) or delete (added),
## Home back to the original, Esc deselect, E wall finish (elewacja).
##
## Windows and doors (O with a house selected): LEFT click on a wall selects an opening (drag moves it, also onto
## another wall) or, with a kind chosen in the panel, puts a new one there. [ ] width, - = height, PgUp / PgDn up /
## down, , . kind, C copy next to it, X / Del delete, Home back to the automatic layout, Esc / O leave.
## The first change turns the automatic layout into the building's own list ("openings" in overrides.json).

const NEW_W := 10.0
const NEW_D := 8.0

var ed: MapEditor
var bs: BuildingSet
var sel := -1
var armed := ""
var _drag := false
var _drag_moved := false
var _drag_ground := Vector2.ZERO
var _buttons := {}
var _group := ButtonGroup.new()
## windows and doors mode
var op_mode := false
var op_sel := -1            # index in the selected building's openings
var op_kind := ""           # armed kind for new openings ("" = select / move only)
var _op_drag := false
var _op_moved := false
var _op_grab := Vector2.ZERO    # where on the opening it was grabbed: (metres from the centre, metres above the bottom)
var _op_buttons := {}
var _op_group := ButtonGroup.new()
var _op_toggle: Button
var _type_box: VBoxContainer    # building types and their actions (hidden in the windows-and-doors mode)
var _op_box: VBoxContainer      # opening kinds (shown only in that mode)
var _op_only: Array = []        # buttons shown only in that mode


func _init(p_ed: MapEditor, p_bs: BuildingSet) -> void:
	ed = p_ed
	bs = p_bs


# ------------------------------------------------------------------ panel

func build_panel(outer: VBoxContainer) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	outer.add_child(box)
	_type_box = box
	box.add_child(ed._label("Typ budynku: klik zmienia zaznaczony,\nbez zaznaczenia stawia nowy", 12, Color(0.7, 0.8, 0.9)))
	_add_button(box, "", "Wybierz / przesuwaj")
	var i := 1
	for a in bs.arch_order:
		_add_button(box, String(a), "%d. %s" % [i, String(bs.archetypes[a]["label"])])
		i += 1
	var row := HBoxContainer.new()
	box.add_child(row)
	for spec in [["Zapisz F5", "save"], ["Cofnij U", "undo"], ["Ukryj/Usuń X", "delete"], ["Kopiuj C", "dup"]]:
		row.add_child(_action_button(spec[0], spec[1]))
	var row2 := HBoxContainer.new()
	box.add_child(row2)
	for spec in [["Prostokąt B", "rect"], ["Kalenica V", "ridge"], ["Kolor N", "tint"], ["Oryginał Home", "reset"]]:
		row2.add_child(_action_button(spec[0], spec[1]))
	box.add_child(ed._label("LPM wybór / przeciąganie, kółko/R/T obrót, [ ] rozmiar,\nPgUp/PgDn piętra, , . poprzedni/następny typ,\nV kalenica, B prostokąt, N kolor, E elewacja, Esc odznacz", 11, Color(0.75, 0.75, 0.75)))
	var row3 := HBoxContainer.new()
	outer.add_child(row3)
	_op_toggle = _action_button("Okna i drzwi O", "openings")
	_op_toggle.toggle_mode = true
	row3.add_child(_op_toggle)
	row3.add_child(_action_button("Elewacja E", "facade"))
	for spec in [["Zapisz F5", "save"], ["Cofnij U", "undo"]]:     # the type list with its own copies is hidden then
		var b := _action_button(spec[0], spec[1])
		b.visible = false
		row3.add_child(b)
		_op_only.append(b)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	box.visible = false
	outer.add_child(box)
	_op_box = box
	box.add_child(ed._label("Okna i drzwi: klik zmienia zaznaczony otwór,\nbez zaznaczenia klik w ścianę stawia nowy", 12, Color(0.7, 0.8, 0.9)))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 2)
	box.add_child(grid)
	_add_op_button(grid, "", "Wybierz / przesuwaj")
	for k in BuildingKit.OPENING_ORDER:
		_add_op_button(grid, k, String(BuildingKit.OPENING_KINDS[k]["label"]))
	box.add_child(ed._label("LPM w ścianę: wybór / przeciąganie / nowy,\n[ ] szerokość, - = wysokość, PgUp/PgDn w górę/dół\n(Shift = drobniej), , . rodzaj, C kopia obok, X usuń,\nE elewacja, Home automatyczne, O / Esc koniec", 11, Color(0.75, 0.75, 0.75)))


func _add_op_button(parent: Control, kind: String, text: String) -> void:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.button_group = _op_group
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(158, 0)
	b.add_theme_font_size_override("font_size", 12)
	b.pressed.connect(_on_op_kind.bind(kind))
	parent.add_child(b)
	_op_buttons[kind] = b
	if kind == "":
		b.button_pressed = true


func _on_op_kind(kind: String) -> void:
	if sel == -1:
		_sync_op_buttons()
		ed._update_status("Najpierw zaznacz budynek.")
		return
	if not op_mode:
		set_op_mode(true)
	if kind != "" and op_sel != -1:
		set_opening_kind(kind)
		op_kind = ""
	else:
		op_kind = kind
	_sync_op_buttons()
	ed._update_status()


func _sync_op_buttons() -> void:
	if _op_buttons.has(op_kind):
		(_op_buttons[op_kind] as Button).button_pressed = true
	if _op_toggle != null:
		_op_toggle.set_pressed_no_signal(op_mode)
	if _op_box != null and _op_box.visible != op_mode:
		_op_box.visible = op_mode
		_type_box.visible = not op_mode
		for b in _op_only:
			(b as Button).visible = op_mode
		ed._panel.reset_size()


func _add_button(parent: Control, arch: String, text: String) -> void:
	var b := Button.new()
	b.text = text
	b.toggle_mode = true
	b.button_group = _group
	b.focus_mode = Control.FOCUS_NONE
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 12)
	b.pressed.connect(_on_type.bind(arch))
	parent.add_child(b)
	_buttons[arch] = b
	if arch == "":
		b.button_pressed = true


func _action_button(text: String, what: String) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 12)
	b.pressed.connect(_on_action.bind(what))
	return b


func _on_type(arch: String) -> void:
	if arch != "" and sel != -1:
		set_arch(arch)
		(_buttons[""] as Button).button_pressed = true
		return
	arm(arch)


func _on_action(what: String) -> void:
	match what:
		"save": ed.save()
		"undo": ed.undo()
		"delete": remove_selected()
		"dup": duplicate_selected()
		"rect": toggle_rect()
		"ridge": toggle_ridge()
		"tint": next_tint()
		"reset": reset_selected()
		"openings": set_op_mode(not op_mode)
		"facade": next_facade()
	ed._update_status()


# ------------------------------------------------------------------ state

func arm(arch: String) -> void:
	armed = arch
	if armed != "":
		select(-1)
	if _buttons.has(arch):
		(_buttons[arch] as Button).button_pressed = true
	ed._update_status()


## Selecting lifts the building out of the merged mesh (one rebuild of the town), so edits rebuild one house.
func select(id: int) -> void:
	sel = id
	op_sel = -1
	_op_drag = false
	if id == -1 and op_mode:
		op_mode = false
		op_kind = ""
		_sync_op_buttons()
	if id == -1:
		bs.drop()
	else:
		bs.lift(id)
	ed._update_status()


func on_leave() -> void:
	_drag = false
	op_mode = false
	op_kind = ""
	_sync_op_buttons()
	armed = ""
	if _buttons.has(""):
		(_buttons[""] as Button).button_pressed = true
	select(-1)


func after_undo() -> void:
	if sel != -1 and not bs.entries.has(sel):
		sel = -1
	if sel == -1 or op_sel >= openings_of(sel).size():
		op_sel = -1
	if sel != -1:
		bs.lifted = -1
		bs.lift(sel)


func _changed() -> void:
	bs.rebuild_lifted()
	ed.dirty = true
	ed._update_status()


# ------------------------------------------------------------------ editing actions

func set_arch(arch: String) -> void:
	if sel == -1 or not bs.archetypes.has(arch):
		return
	ed._push_undo()
	bs.set_ov(sel, "arch", arch)
	bs.set_ov(sel, "storeys", null)      # the new type brings its own storey count
	bs.set_ov(sel, "tint", null)
	_changed()


func step_arch(dir: int) -> void:
	if sel == -1:
		return
	var i := bs.arch_order.find(bs.arch_id(sel))
	set_arch(String(bs.arch_order[posmod(i + dir, bs.arch_order.size())]))


func place(arch: String, g: Vector2) -> int:
	ed._push_undo()
	var id := bs.add_building(arch, Vector2(snappedf(g.x, 0.1), snappedf(g.y, 0.1)), NEW_W, NEW_D)
	select(id)
	ed.dirty = true
	return id


func rotate_selected(deg: float) -> void:
	if sel == -1:
		return
	ed._push_undo()
	bs.set_ov(sel, "yaw", snappedf(fposmod(float(bs.get_ov(sel, "yaw", 0.0)) + deg_to_rad(deg), TAU), 0.0001))
	_changed()


func scale_selected(factor: float) -> void:
	if sel == -1:
		return
	ed._push_undo()
	bs.set_ov(sel, "scale", snappedf(clampf(float(bs.get_ov(sel, "scale", 1.0)) * factor, 0.3, 4.0), 0.001))
	_changed()


func change_storeys(d: int) -> void:
	if sel == -1:
		return
	var arch: Dictionary = bs.archetypes[bs.arch_id(sel)]
	var cur := bs.storeys_of(sel)
	if cur <= 0:      # a public building keeps its OSM height until the author sets storeys
		cur = clampi(int(round(BuildingKit.wall_height(arch, 0, float(bs.entries[sel]["height"])) / float(arch["storey_h"]))), 1, 6)
	var n := clampi(cur + d, 1, 6)
	ed._push_undo()
	bs.set_ov(sel, "storeys", n)
	_changed()


func toggle_ridge() -> void:
	if sel == -1:
		return
	ed._push_undo()
	bs.set_ov(sel, "ridge", null if bool(bs.get_ov(sel, "ridge", false)) else true)
	_changed()


func toggle_rect() -> void:
	if sel == -1:
		return
	ed._push_undo()
	bs.set_ov(sel, "rect", null if bool(bs.get_ov(sel, "rect", false)) else true)
	_changed()


func next_tint() -> void:
	if sel == -1:
		return
	var n := (bs.archetypes[bs.arch_id(sel)]["tints"] as Array).size()
	var cur := int(bs.get_ov(sel, "tint", absi(sel) % n))
	ed._push_undo()
	bs.set_ov(sel, "tint", (cur + 1) % n)
	_changed()


func remove_selected() -> void:
	if sel == -1:
		return
	ed._push_undo()
	var was_added := bs.is_added(sel)
	bs.remove_building(sel)
	ed.dirty = true
	if was_added:
		sel = -1
		bs.build_all()
		ed._update_status("Usunięto dodany budynek.")
	else:
		_changed()


func duplicate_selected() -> void:
	if sel == -1:
		return
	ed._push_undo()
	var id := bs.duplicate_building(sel, Vector2(4.0, 4.0))
	ed.dirty = true
	select(id)


func reset_selected() -> void:
	if sel == -1:
		return
	ed._push_undo()
	bs.reset_building(sel)
	op_sel = -1
	_changed()


func next_facade() -> void:
	if sel == -1:
		return
	var cur := String(bs.get_ov(sel, "facade", bs.archetypes[bs.arch_id(sel)]["wall"]))
	var i := -1
	for k in range(BuildingKit.FACADES.size()):
		if BuildingKit.FACADES[k][0] == cur:
			i = k
	var nxt := String(BuildingKit.FACADES[(i + 1) % BuildingKit.FACADES.size()][0])
	ed._push_undo()
	bs.set_ov(sel, "facade", null if nxt == String(bs.archetypes[bs.arch_id(sel)]["wall"]) else nxt)
	_changed()


# ------------------------------------------------------------------ windows and doors

func set_op_mode(on: bool) -> void:
	if on and sel == -1:
		ed._update_status("Najpierw zaznacz budynek.")
		on = false
	op_mode = on
	op_sel = -1
	_op_drag = false
	if not on:
		op_kind = ""
	_sync_op_buttons()
	ed._update_status()


## The openings in use: the author's list, or the automatic layout of the last build.
func openings_of(id: int) -> Array:
	var own = bs.get_ov(id, "openings")
	if own != null:
		return own
	return bs.info(id).get("openings", [])


func has_own_openings(id: int) -> bool:
	return bs.get_ov(id, "openings") != null


## Before the first change the automatic layout becomes the building's own list.
func _own_openings() -> Array:
	if not has_own_openings(sel):
		bs.set_ov(sel, "openings", (bs.info(sel).get("openings", []) as Array).duplicate(true))
	return bs.get_ov(sel, "openings")


## The wall of the selected building under a ray: {e, s (metres along it), y, len} or {} (none).
func wall_hit(origin: Vector3, dir: Vector3) -> Dictionary:
	var inf := bs.info(sel)
	if inf.is_empty():
		return {}
	var wall_h := float(inf["wall_h"])
	var o2 := Vector2(origin.x, origin.z)
	var d2 := Vector2(dir.x, dir.z)
	if d2.length() < 0.0001:
		return {}
	var best := {}
	var best_k := INF
	var walls: Array = inf.get("walls", [])
	for e in range(walls.size()):
		var w: Dictionary = walls[e]
		if float(w["len"]) < 0.5:
			continue
		var p = Geometry2D.segment_intersects_segment(o2, o2 + d2 * (600.0 / d2.length()), w["a"], w["b"])
		if p == null:
			continue
		var k: float = ((p as Vector2) - o2).length() / d2.length()
		var y := origin.y + dir.y * k
		if y < 0.0 or y > wall_h or k >= best_k:
			continue
		best_k = k
		best = {"e": e, "s": ((p as Vector2) - (w["a"] as Vector2)).length(), "y": y, "len": float(w["len"])}
	return best


## Index of the opening under a wall hit (the newest when they overlap), -1 = none.
func opening_at(hit: Dictionary) -> int:
	var list := openings_of(sel)
	for i in range(list.size() - 1, -1, -1):     # the newest first: it is drawn on top
		var o: Dictionary = list[i]
		if int(o["e"]) != int(hit["e"]):
			continue
		var cs := float(o["t"]) * float(hit["len"])
		if absf(float(hit["s"]) - cs) <= float(o["w"]) * 0.5 + 0.05 and float(hit["y"]) >= float(o["y"]) - 0.05 \
				and float(hit["y"]) <= float(o["y"]) + float(o["h"]) + 0.05:
			return i
	return -1


func _kind_y(kind: String, y: float) -> float:
	if bool(BuildingKit.OPENING_KINDS[kind].get("ground", false)):
		return 0.0
	return snappedf(maxf(y, 0.0), 0.05)


## A new opening of `kind` centred at the wall hit (doors on the ground). Returns its index.
func add_opening(kind: String, hit: Dictionary) -> int:
	var spec: Dictionary = BuildingKit.OPENING_KINDS[kind]
	var list := _own_openings()
	var h := float(spec["h"])
	list.append({"e": int(hit["e"]), "t": snappedf(float(hit["s"]) / float(hit["len"]), 0.0001),
		"y": _kind_y(kind, float(hit["y"]) - h * 0.5), "w": float(spec["w"]), "h": h, "k": kind})
	op_sel = list.size() - 1
	_changed()
	return op_sel


func set_opening_kind(kind: String) -> void:
	if op_sel == -1:
		return
	ed._push_undo()
	var o: Dictionary = _own_openings()[op_sel]
	var spec: Dictionary = BuildingKit.OPENING_KINDS[kind]
	var was_ground := bool(BuildingKit.OPENING_KINDS.get(String(o["k"]), {}).get("ground", false))
	o["k"] = kind
	o["w"] = float(spec["w"])
	o["h"] = float(spec["h"])
	if bool(spec.get("ground", false)):
		o["y"] = 0.0
	elif was_ground:
		o["y"] = float(spec["y"])
	_changed()


func step_opening_kind(dir: int) -> void:
	if op_sel == -1:
		return
	var cur := String(openings_of(sel)[op_sel]["k"])
	var i := BuildingKit.OPENING_ORDER.find(cur)
	set_opening_kind(String(BuildingKit.OPENING_ORDER[posmod(i + dir, BuildingKit.OPENING_ORDER.size())]))


func resize_opening(dw: float, dh: float) -> void:
	if op_sel == -1:
		return
	ed._push_undo()
	var o: Dictionary = _own_openings()[op_sel]
	o["w"] = snappedf(clampf(float(o["w"]) + dw, 0.3, 8.0), 0.01)
	o["h"] = snappedf(clampf(float(o["h"]) + dh, 0.3, 8.0), 0.01)
	_changed()


func raise_opening(dy: float) -> void:
	if op_sel == -1:
		return
	ed._push_undo()
	var o: Dictionary = _own_openings()[op_sel]
	o["y"] = snappedf(maxf(float(o["y"]) + dy, 0.0), 0.01)
	_changed()


func delete_opening() -> void:
	if op_sel == -1:
		return
	ed._push_undo()
	_own_openings().remove_at(op_sel)
	op_sel = -1
	_changed()


## A copy right next to the selected opening (to the right along the wall, or to the left when there is no room).
func copy_opening() -> void:
	if op_sel == -1:
		return
	ed._push_undo()
	var list := _own_openings()
	var o: Dictionary = (list[op_sel] as Dictionary).duplicate()
	var length := float((bs.info(sel)["walls"] as Array)[int(o["e"])]["len"])
	var step := (float(o["w"]) + 0.8) / length
	var t := float(o["t"]) + step
	if t * length + float(o["w"]) * 0.5 > length - 0.1:
		t = float(o["t"]) - step
	o["t"] = snappedf(clampf(t, 0.0, 1.0), 0.0001)
	list.append(o)
	op_sel = list.size() - 1
	_changed()


func reset_openings() -> void:
	if sel == -1 or not has_own_openings(sel):
		return
	ed._push_undo()
	bs.set_ov(sel, "openings", null)
	op_sel = -1
	_changed()
	ed._update_status("Okna i drzwi wróciły do automatycznego układu.")


func _op_press() -> void:
	var r := ed._ray_from_mouse()
	var hit := wall_hit(r[0], r[1])
	if hit.is_empty():
		var id := bs.pick(r[0], r[1])
		if id != -1 and id != sel:
			select(id)        # another house: stay in this mode, now on that one
			op_mode = true
			_sync_op_buttons()
		else:
			op_sel = -1
		ed._update_status()
		return
	var idx := opening_at(hit)
	ed._push_undo()
	_op_moved = false
	if idx == -1:
		if op_kind == "":
			ed._undo.pop_back()
			op_sel = -1
			ed._update_status("Wybierz rodzaj w panelu (Okno, Drzwi...), aby postawić nowy otwór.")
			return
		add_opening(op_kind, hit)
		_op_moved = true      # keep the undo step
		idx = op_sel
	op_sel = idx
	var o: Dictionary = openings_of(sel)[idx]
	_op_grab = Vector2(float(hit["s"]) - float(o["t"]) * float(hit["len"]), float(hit["y"]) - float(o["y"]))
	_op_drag = true
	ed._update_status()


func _op_motion() -> void:
	if not _op_drag or op_sel == -1:
		return
	var r := ed._ray_from_mouse()
	var hit := wall_hit(r[0], r[1])
	if hit.is_empty():
		return
	var list := _own_openings()
	var o: Dictionary = list[op_sel]
	var length := float(hit["len"])
	var s := clampf(float(hit["s"]) - _op_grab.x, float(o["w"]) * 0.5, length - float(o["w"]) * 0.5)
	var t := snappedf(snappedf(s, 0.05) / length, 0.0001)
	var y := _kind_y(String(o["k"]), float(hit["y"]) - _op_grab.y)
	if int(o["e"]) == int(hit["e"]) and absf(t - float(o["t"])) < 0.00005 and absf(y - float(o["y"])) < 0.001:
		return
	o["e"] = int(hit["e"])
	o["t"] = t
	o["y"] = y
	_op_moved = true
	bs.rebuild_lifted()
	ed.dirty = true


func _op_release() -> void:
	if _op_drag and not _op_moved and ed._undo.size() > 0:
		ed._undo.pop_back()       # a plain click changed nothing
	_op_drag = false
	ed._update_status()


func _op_key(e: InputEventKey) -> bool:
	var fine := e.shift_pressed
	match e.keycode:
		KEY_BRACKETLEFT: resize_opening(-(0.05 if fine else 0.1), 0.0)
		KEY_BRACKETRIGHT: resize_opening(0.05 if fine else 0.1, 0.0)
		KEY_MINUS: resize_opening(0.0, -(0.05 if fine else 0.1))
		KEY_EQUAL: resize_opening(0.0, 0.05 if fine else 0.1)
		KEY_PAGEUP: raise_opening(0.05 if fine else 0.1)
		KEY_PAGEDOWN: raise_opening(-(0.05 if fine else 0.1))
		KEY_COMMA: step_opening_kind(-1)
		KEY_PERIOD: step_opening_kind(1)
		KEY_C: copy_opening()
		KEY_DELETE, KEY_X: delete_opening()
		KEY_HOME: reset_openings()
		KEY_E: next_facade()
		KEY_O: set_op_mode(false)
		KEY_ESCAPE:
			_op_drag = false
			if op_sel != -1:
				op_sel = -1
			elif op_kind != "":
				op_kind = ""
				_sync_op_buttons()
			else:
				set_op_mode(false)
		_:
			return false
	return true


# ------------------------------------------------------------------ input (called by MapEditor)

func left_press() -> void:
	if op_mode:
		_op_press()
		return
	var r := ed._ray_from_mouse()
	var g = ed.ground_hit(r[0], r[1])
	if armed != "":
		if g != null:
			place(armed, g)
			_start_drag(g)
		return
	var id := bs.pick(r[0], r[1])
	if id == -1 and g != null:
		id = bs.hidden_at(g)
	if id == -1:
		select(-1)
		return
	if id != sel:
		select(id)
	ed._push_undo()
	_start_drag(g if g != null else Vector2.ZERO)


func _start_drag(g: Vector2) -> void:
	_drag = true
	_drag_moved = false
	_drag_ground = g


func drag_motion() -> void:
	if op_mode:
		_op_motion()
		return
	if not _drag or sel == -1:
		return
	var r := ed._ray_from_mouse()
	var g = ed.ground_hit(r[0], r[1])
	if g == null:
		return
	var delta: Vector2 = g - _drag_ground
	if delta.length() < 0.02:
		return
	_drag_moved = true
	_drag_ground = g
	bs.set_ov(sel, "dx", snappedf(float(bs.get_ov(sel, "dx", 0.0)) + delta.x, 0.01))
	bs.set_ov(sel, "dz", snappedf(float(bs.get_ov(sel, "dz", 0.0)) + delta.y, 0.01))
	bs.rebuild_lifted()
	ed.dirty = true


func left_release() -> void:
	if op_mode:
		_op_release()
		return
	if _drag and not _drag_moved and armed == "" and ed._undo.size() > 0:
		ed._undo.pop_back()       # a plain click moved nothing
	_drag = false
	if armed != "":
		arm("")
	ed._update_status()


func wheel(up: bool) -> void:
	if op_mode:
		return      # no accidental turning of the house while placing windows
	var step := 45.0 if Input.is_key_pressed(KEY_SHIFT) else 5.0
	rotate_selected(step if up else -step)


## Returns true when the key was used here.
func key(e: InputEventKey) -> bool:
	if op_mode:
		return _op_key(e)
	match e.keycode:
		KEY_O: set_op_mode(true)
		KEY_E: next_facade()
		KEY_R: rotate_selected(15.0)
		KEY_T: rotate_selected(-15.0)
		KEY_BRACKETLEFT: scale_selected(1.0 / 1.05)
		KEY_BRACKETRIGHT: scale_selected(1.05)
		KEY_PAGEUP: change_storeys(1)
		KEY_PAGEDOWN: change_storeys(-1)
		KEY_COMMA: step_arch(-1)
		KEY_PERIOD: step_arch(1)
		KEY_V: toggle_ridge()
		KEY_B: toggle_rect()
		KEY_N: next_tint()
		KEY_DELETE, KEY_X: remove_selected()
		KEY_C: duplicate_selected()
		KEY_HOME: reset_selected()
		KEY_ESCAPE:
			_drag = false
			if armed != "":
				arm("")
			else:
				select(-1)
		_:
			return false
	return true


# ------------------------------------------------------------------ status and overlay

func status() -> String:
	if armed != "":
		return "Kliknij na ziemi, aby postawić: %s (%d x %d m; potem [ ] rozmiar, R/T obrót). Esc anuluje." % [
			String(bs.archetypes[armed]["label"]), int(NEW_W), int(NEW_D)]
	if sel == -1:
		return "Kliknij budynek (ściana albo dach). Ukryte budynki: kliknij w ich czerwony obrys."
	var arch: Dictionary = bs.archetypes[bs.arch_id(sel)]
	var inf := bs.info(sel)
	var lines: Array = []
	lines.append("%s #%d: %s%s" % ["Dodany" if bs.is_added(sel) else "Budynek OSM", sel, String(arch["label"]),
		"  (domyślny)" if bs.get_ov(sel, "arch") == null and not bs.is_added(sel) else ""])
	if bs.is_hidden(sel):
		lines.append("UKRYTY: X przywraca.")
	else:
		var st := bs.storeys_of(sel)
		lines.append("Piętra: %s  wys. ścian %.1f m  szczyt %.1f m  obrót %d°  rozmiar %.2f" % [
			str(st) if st > 0 else "z danych", float(inf.get("wall_h", 0.0)), float(inf.get("top", 0.0)),
			int(round(rad_to_deg(float(bs.get_ov(sel, "yaw", 0.0))))) % 360, float(bs.get_ov(sel, "scale", 1.0))])
		if bool(inf.get("irregular", false)):
			lines.append("Obrys nieregularny, więc dach płaski. B = uprość do prostokąta.")
		var fac = bs.get_ov(sel, "facade")
		lines.append("Elewacja: %s%s.  Okna i drzwi: %d, %s." % [
			BuildingKit.facade_label(String(fac if fac != null else arch["wall"])), "" if fac != null else " (z typu)",
			openings_of(sel).size(), "ustawione ręcznie" if has_own_openings(sel) else "automatyczne"])
		if op_mode:
			lines.append(_op_status())
		else:
			lines.append("O = okna i drzwi, E = elewacja.")
	return "\n".join(lines)


func _op_status() -> String:
	if op_sel != -1 and op_sel < openings_of(sel).size():
		var o: Dictionary = openings_of(sel)[op_sel]
		var kind := String(BuildingKit.OPENING_KINDS.get(String(o["k"]), {"label": o["k"]})["label"])
		return "OKNA I DRZWI. Zaznaczony: %s %.2f x %.2f m, ściana %d, dół %.2f m nad ziemią.\nPrzeciągnij, [ ] szerokość, - = wysokość, PgUp/PgDn w górę/dół, , . rodzaj, C kopia, X usuń." % [
			kind, float(o["w"]), float(o["h"]), int(o["e"]) + 1, float(o["y"])]
	if op_kind != "":
		return "OKNA I DRZWI. Kliknij ścianę, aby postawić: %s. Esc = tylko wybór." % String(BuildingKit.OPENING_KINDS[op_kind]["label"])
	return "OKNA I DRZWI. Kliknij okno lub drzwi na ścianie, aby je zaznaczyć. Nowy: wybierz rodzaj w panelu. Home = automatyczne, O / Esc = wyjście."


func draw() -> void:
	for id in bs.order:
		if bs.is_hidden(id) and id != sel:
			_outline(bs.ring_of(id), 0.0, Color(0.9, 0.2, 0.2))
	if sel != -1 and bs.entries.has(sel):
		var inf := bs.info(sel)
		var c := Color(0.9, 0.2, 0.2) if bs.is_hidden(sel) else Color(1.0, 0.9, 0.2)
		_outline(bs.ring_of(sel), float(inf.get("wall_h", 0.0)), c * (0.5 if op_mode else 1.0))
		if op_mode and not inf.is_empty():
			_draw_openings_overlay(inf)
	if armed != "" and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not ed._over_panel():
		var r := ed._ray_from_mouse()
		var g = ed.ground_hit(r[0], r[1])
		if g != null:
			var ring := PackedVector2Array()
			for k in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				ring.append(g + k * Vector2(NEW_W, NEW_D) * 0.5)
			_outline(ring, 0.0, Color(0.3, 1.0, 0.3))


func _outline(ring: PackedVector2Array, h: float, c: Color) -> void:
	for i in range(ring.size()):
		var a := ring[i]
		var b := ring[(i + 1) % ring.size()]
		ed._line(Vector3(a.x, 0.15, a.y), Vector3(b.x, 0.15, b.y), c)
		if h > 0.0:
			ed._line(Vector3(a.x, h + 0.05, a.y), Vector3(b.x, h + 0.05, b.y), c)
			ed._line(Vector3(a.x, 0.15, a.y), Vector3(a.x, h + 0.05, a.y), c)


func _draw_openings_overlay(inf: Dictionary) -> void:
	var walls: Array = inf.get("walls", [])
	var list := openings_of(sel)
	for i in range(list.size()):
		var o: Dictionary = list[i]
		var e := int(o["e"])
		if e >= walls.size():
			continue
		var fit := BuildingKit.fit_opening(o, float(walls[e]["len"]), float(inf["wall_h"]))
		if fit.is_empty():
			continue
		_rect_on_wall(walls[e], fit["s"], fit["y"], fit["w"], fit["h"], Color(1.0, 0.9, 0.2) if i == op_sel else Color(0.3, 0.85, 1.0))
	if op_kind != "" and not _op_drag and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not ed._over_panel():
		var r := ed._ray_from_mouse()
		var hit := wall_hit(r[0], r[1])
		if not hit.is_empty():
			var spec: Dictionary = BuildingKit.OPENING_KINDS[op_kind]
			var h := float(spec["h"])
			_rect_on_wall(walls[int(hit["e"])], float(hit["s"]), _kind_y(op_kind, float(hit["y"]) - h * 0.5), float(spec["w"]), h,
				Color(0.3, 1.0, 0.3))


func _rect_on_wall(w: Dictionary, s: float, y: float, width: float, h: float, c: Color) -> void:
	var a: Vector2 = w["a"]
	var dir := ((w["b"] as Vector2) - a).normalized()
	var n: Vector2 = w["n"]
	var p0 := a + dir * (s - width * 0.5) + n * 0.08
	var p1 := a + dir * (s + width * 0.5) + n * 0.08
	var q := [Vector3(p0.x, y, p0.y), Vector3(p1.x, y, p1.y), Vector3(p1.x, y + h, p1.y), Vector3(p0.x, y + h, p0.y)]
	for k in range(4):
		ed._line(q[k], q[(k + 1) % 4], c)
