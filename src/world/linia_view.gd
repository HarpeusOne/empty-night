extends LookGateView
class_name LiniaView

## The PS2-look view (low-res viewport, post effect, phase keys) showing the OSM greybox of the centre of Linia.

const LEVEL = preload("res://src/world/blockout_level.gd")


func _make_world() -> PS2WorldBase:
	return LEVEL.new()

var editor: MapEditor


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		toggle_editor()
		return
	super._input(event)


func toggle_editor() -> void:
	if editor == null:
		editor = MapEditor.new()
		editor.view = self
		editor.world = world
		editor.props = world.get("props")
		add_child(editor)
	editor.set_active(not editor.active)
