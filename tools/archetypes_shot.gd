extends SceneTree

## Every house archetype side by side on an empty field outside the village (nothing is saved).
## Output: docs/look/arch/<archetype>.png; tools/art/arch_sheet.py joins them into docs/look/archetypes.png.
const ViewScript = preload("res://src/world/linia_view.gd")
const SIZES := {"garaz": Vector2(6, 4.5), "blok": Vector2(22, 11), "sklep": Vector2(14, 10), "stodola": Vector2(15, 9),
	"obora": Vector2(14, 7), "kostka": Vector2(10, 10), "publiczny": Vector2(16, 12)}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var view = ViewScript.new()
	view.capture_mouse = false
	root.add_child(view)
	for i in range(4):
		await process_frame
	var world = view.world
	var bs: BuildingSet = world.buildings
	var order: Array = bs.arch_order
	var half := int(ceil(order.size() / 2.0))
	var rows := [order.slice(0, half), order.slice(half)]
	var z0 := 700.0
	for r in range(2):
		var x := 700.0
		for a in rows[r]:
			var sz: Vector2 = SIZES.get(a, Vector2(11, 8.5))
			x += sz.x * 0.5
			var id := bs.add_building(String(a), Vector2(x, z0 + r * 200.0), sz.x, sz.y)
			bs.set_ov(id, "tint", 0)
			x += sz.x * 0.5 + 7.0
	bs.build_all()
	world.debug_fog_off = true
	world.set_phase("day")
	view.show_help(false)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/look/arch"))
	var placed := {}
	for id in bs.order:
		if bs.is_added(id):
			placed[bs.arch_id(id)] = BuildingKit.centroid(bs.ring_of(id))
	for a in order:
		var c: Vector2 = placed[a]
		var sz: Vector2 = SIZES.get(a, Vector2(11, 8.5))
		var dist := maxf(sz.x, 9.0) * 1.25 + 6.0
		view.set_camera(Vector3(c.x - dist * 0.55, 5.5, c.y + dist), Vector3(c.x, 3.0, c.y))
		for i in range(4):
			await RenderingServer.frame_post_draw
		var img := root.get_viewport().get_texture().get_image()
		img.resize(480, 360)
		img.save_png(ProjectSettings.globalize_path("res://docs/look/arch/%s.png" % a))
	print("shots: ", order.size())
	quit()
