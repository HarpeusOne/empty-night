extends SceneTree

## Checks how well the church model sits on its OSM footprint: reports how many model corner points fall inside it.
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
	var pts := {"back_l": [-21.7, -7.85], "back_r": [-21.7, 7.85], "nave_l": [0.0, -7.85], "nave_r": [0.0, 7.85],
		"front_l": [15.3, -9.1], "front_r": [15.3, 9.1], "tower": [15.3, 0.0], "porch_tip": [19.0, 0.0],
		"leanto_l": [-1.0, -9.25], "leanto_r": [-1.0, 9.25]}
	for k in pts:
		var q: Vector3 = m.pt(pts[k][0], pts[k][1], 0.0)
		var inside: bool = level.point_in_footprint(Vector2(q.x, q.z)) != -1
		print("%-10s %s inside_footprint=%s" % [k, str(Vector2(q.x, q.z)), inside])
	print("footprint ring: ", fp["ring"])
	quit()
