extends SceneTree

## Writes data/map/props.json from the default church-yard layout (only when the file does not exist yet).
const LevelScene = preload("res://scenes/linia_centrum.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var level = LevelScene.instantiate()
	level.spawn_walker = false
	root.add_child(level)
	await process_frame
	if FileAccess.file_exists("res://data/map/props.json"):
		print("props.json exists, not overwritten")
	else:
		print("saved: ", level.props.save_file(), " items=", level.props.items.size())
	quit()
