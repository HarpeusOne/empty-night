extends SceneTree

## Prints the OSM footprint of the church in the model's own frame (s along the nave, t across).
const ViewScript = preload("res://src/world/linia_view.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(3):
		await process_frame
	var level = view.world
	var fp = null
	for f in level.footprints:
		if f["kind"] == "church":
			fp = f
	var c := Vector2.ZERO
	for p in fp["ring"]:
		c += p
	c /= fp["ring"].size()
	var m := ChurchModel.new(null, Vector2(c.x, -c.y), level.CHURCH_HEADING_DEG)
	for p in fp["ring"]:
		# model frame: pt(s,t) = origin + u*s + v*t, godot z = -north
		var en := Vector2(p.x, -p.y)
		var d := en - m.origin
		print("s=%7.2f  t=%7.2f" % [d.dot(m.u), d.dot(m.v)])
	quit()
