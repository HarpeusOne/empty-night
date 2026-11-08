class_name LowPoly
extends RefCounted

## Tiny mesh kit for low-poly scenes: one surface per material key, per-vertex colour (baked AO / tint),
## per-vertex normals (for the vertex lighting in ps2_surface.gdshader) and UVs in world units.
##
## Quads and boxes take points counter-clockwise as seen from OUTSIDE; the normal is derived from that order,
## and `tri` fixes the winding for Godot (clockwise front faces). A wrong order shows up as a dark or missing face.

var _tools: Dictionary = {}
var _order: Array[String] = []


func _tool(key: String) -> SurfaceTool:
	if not _tools.has(key):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		_tools[key] = st
		_order.append(key)
	return _tools[key]


func _vert(st: SurfaceTool, p: Vector3, uv: Vector2, c: Color, n: Vector3) -> void:
	st.set_color(c)
	st.set_normal(n)
	st.set_uv(uv)
	st.add_vertex(p)


func tri(key: String, a: Vector3, b: Vector3, c: Vector3, uva: Vector2, uvb: Vector2, uvc: Vector2,
		ca: Color, cb: Color, cc: Color, na: Vector3, nb: Vector3, nc: Vector3) -> void:
	if (b - a).cross(c - a).dot(na + nb + nc) > 0.0:
		var p := b; b = c; c = p
		var u := uvb; uvb = uvc; uvc = u
		var k := cb; cb = cc; cc = k
		var n := nb; nb = nc; nc = n
	var st := _tool(key)
	_vert(st, a, uva, ca, na)
	_vert(st, b, uvb, cb, nb)
	_vert(st, c, uvc, cc, nc)


func tri_flat(key: String, a: Vector3, b: Vector3, c: Vector3, uva: Vector2, uvb: Vector2, uvc: Vector2,
		ca: Color = Color.WHITE, cb: Color = Color.WHITE, cc: Color = Color.WHITE) -> void:
	var n := (b - a).cross(c - a).normalized()
	tri(key, a, b, c, uva, uvb, uvc, ca, cb, cc, n, n, n)


static func _bil(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, s: float, t: float) -> Vector3:
	return p0.lerp(p1, s).lerp(p3.lerp(p2, s), t)


static func _bil2(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, s: float, t: float) -> Vector2:
	return p0.lerp(p1, s).lerp(p3.lerp(p2, s), t)


## A quad p0(bottom-left) p1(bottom-right) p2(top-right) p3(top-left), split into nu x nv cells so vertex
## lighting has enough vertices to work with. Colour goes from `c_bottom` (p0-p1 edge) to `c_top` (p3-p2 edge).
func quad_grid(key: String, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3,
		uv0: Vector2, uv1: Vector2, uv2: Vector2, uv3: Vector2,
		c_bottom: Color = Color.WHITE, c_top: Color = Color.WHITE, nu: int = 1, nv: int = 1) -> void:
	var n := (p1 - p0).cross(p3 - p0).normalized()
	for i in range(nu):
		for j in range(nv):
			var s0 := float(i) / nu
			var s1 := float(i + 1) / nu
			var t0 := float(j) / nv
			var t1 := float(j + 1) / nv
			var a := _bil(p0, p1, p2, p3, s0, t0)
			var b := _bil(p0, p1, p2, p3, s1, t0)
			var c := _bil(p0, p1, p2, p3, s1, t1)
			var d := _bil(p0, p1, p2, p3, s0, t1)
			var ua := _bil2(uv0, uv1, uv2, uv3, s0, t0)
			var ub := _bil2(uv0, uv1, uv2, uv3, s1, t0)
			var uc := _bil2(uv0, uv1, uv2, uv3, s1, t1)
			var ud := _bil2(uv0, uv1, uv2, uv3, s0, t1)
			var c0 := c_bottom.lerp(c_top, t0)
			var c1 := c_bottom.lerp(c_top, t1)
			tri(key, a, b, c, ua, ub, uc, c0, c0, c1, n, n, n)
			tri(key, a, c, d, ua, uc, ud, c0, c1, c1, n, n, n)


## A quad whose front face looks along `out_n`: swaps the left and right corners when the given order faces the
## wrong way, so callers only have to say which side is "outside".
func quad_out(key: String, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3,
		uv0: Vector2, uv1: Vector2, uv2: Vector2, uv3: Vector2, c_bottom: Color, c_top: Color, out_n: Vector3) -> void:
	if (p1 - p0).cross(p3 - p0).dot(out_n) < 0.0:
		quad_grid(key, p1, p0, p3, p2, uv1, uv0, uv3, uv2, c_bottom, c_top)
	else:
		quad_grid(key, p0, p1, p2, p3, uv0, uv1, uv2, uv3, c_bottom, c_top)


func tri_out(key: String, a: Vector3, b: Vector3, c: Vector3, uva: Vector2, uvb: Vector2, uvc: Vector2,
		ca: Color, cb: Color, cc: Color, out_n: Vector3) -> void:
	if (b - a).cross(c - a).dot(out_n) < 0.0:
		tri_flat(key, a, c, b, uva, uvc, uvb, ca, cc, cb)
	else:
		tri_flat(key, a, b, c, uva, uvb, uvc, ca, cb, cc)


## Axis-aligned box. UVs are world units divided by `tile`. Vertex colour darkens towards the bottom.
func box(key: String, center: Vector3, size: Vector3, tile: float = 2.0,
		c_bottom: Color = Color(0.62, 0.60, 0.58), c_top: Color = Color.WHITE, subdiv: float = 2.0) -> void:
	var h := size * 0.5
	var x0 := center.x - h.x
	var x1 := center.x + h.x
	var y0 := center.y - h.y
	var y1 := center.y + h.y
	var z0 := center.z - h.z
	var z1 := center.z + h.z
	var uw := Vector2(size.x / tile, size.y / tile)
	var ud := Vector2(size.z / tile, size.y / tile)
	var nx := maxi(int(ceil(size.x / subdiv)), 1)
	var nz := maxi(int(ceil(size.z / subdiv)), 1)
	var ny := maxi(int(ceil(size.y / subdiv)), 1)
	quad_grid(key, Vector3(x0, y0, z1), Vector3(x1, y0, z1), Vector3(x1, y1, z1), Vector3(x0, y1, z1),
		Vector2(0, uw.y), Vector2(uw.x, uw.y), Vector2(uw.x, 0), Vector2(0, 0), c_bottom, c_top, nx, ny)
	quad_grid(key, Vector3(x1, y0, z0), Vector3(x0, y0, z0), Vector3(x0, y1, z0), Vector3(x1, y1, z0),
		Vector2(0, uw.y), Vector2(uw.x, uw.y), Vector2(uw.x, 0), Vector2(0, 0), c_bottom, c_top, nx, ny)
	quad_grid(key, Vector3(x1, y0, z1), Vector3(x1, y0, z0), Vector3(x1, y1, z0), Vector3(x1, y1, z1),
		Vector2(0, ud.y), Vector2(ud.x, ud.y), Vector2(ud.x, 0), Vector2(0, 0), c_bottom, c_top, nz, ny)
	quad_grid(key, Vector3(x0, y0, z0), Vector3(x0, y0, z1), Vector3(x0, y1, z1), Vector3(x0, y1, z0),
		Vector2(0, ud.y), Vector2(ud.x, ud.y), Vector2(ud.x, 0), Vector2(0, 0), c_bottom, c_top, nz, ny)
	quad_grid(key, Vector3(x0, y1, z1), Vector3(x1, y1, z1), Vector3(x1, y1, z0), Vector3(x0, y1, z0),
		Vector2(0, size.z / tile), Vector2(size.x / tile, size.z / tile), Vector2(size.x / tile, 0), Vector2(0, 0),
		c_top, c_top, nx, nz)


## Cone with smooth side normals (tree crowns). Base circle at `base`, apex `height` above it.
func cone(key: String, base: Vector3, radius: float, height: float, sides: int = 8,
		c_base: Color = Color(0.55, 0.55, 0.55), c_top: Color = Color.WHITE, uv_scale: float = 2.0) -> void:
	for i in range(sides):
		var a0 := TAU * float(i) / sides
		var a1 := TAU * float(i + 1) / sides
		var b0 := base + Vector3(cos(a0) * radius, 0.0, sin(a0) * radius)
		var b1 := base + Vector3(cos(a1) * radius, 0.0, sin(a1) * radius)
		var apex := base + Vector3(0.0, height, 0.0)
		var n0 := Vector3(cos(a0) * height, radius, sin(a0) * height).normalized()
		var n1 := Vector3(cos(a1) * height, radius, sin(a1) * height).normalized()
		var nt := (n0 + n1).normalized()
		var us := float(i) / sides * uv_scale
		var ue := float(i + 1) / sides * uv_scale
		tri(key, b0, b1, apex, Vector2(us, uv_scale), Vector2(ue, uv_scale), Vector2((us + ue) * 0.5, 0.0),
			c_base, c_base, c_top, n0, n1, nt)


## Cylinder with smooth side normals and a top cap (poles, trunks).
func cylinder(key: String, base: Vector3, radius: float, height: float, sides: int = 6,
		c_bottom: Color = Color(0.6, 0.6, 0.6), c_top: Color = Color.WHITE, tile: float = 2.0) -> void:
	for i in range(sides):
		var a0 := TAU * float(i) / sides
		var a1 := TAU * float(i + 1) / sides
		var d0 := Vector3(cos(a0), 0.0, sin(a0))
		var d1 := Vector3(cos(a1), 0.0, sin(a1))
		var b0 := base + d0 * radius
		var b1 := base + d1 * radius
		var t0 := b0 + Vector3(0.0, height, 0.0)
		var t1 := b1 + Vector3(0.0, height, 0.0)
		var us := float(i) / sides * (TAU * radius / tile)
		var ue := float(i + 1) / sides * (TAU * radius / tile)
		var vh := height / tile
		tri(key, b0, b1, t1, Vector2(us, vh), Vector2(ue, vh), Vector2(ue, 0), c_bottom, c_bottom, c_top, d0, d1, d1)
		tri(key, b0, t1, t0, Vector2(us, vh), Vector2(ue, 0), Vector2(us, 0), c_bottom, c_top, c_top, d0, d1, d0)
		var top := base + Vector3(0.0, height, 0.0)
		tri(key, t0, t1, top, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, c_top, c_top, c_top, Vector3.UP, Vector3.UP, Vector3.UP)


func build(materials: Dictionary) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for key in _order:
		(_tools[key] as SurfaceTool).commit(mesh)
		var idx := mesh.get_surface_count() - 1
		if materials.has(key):
			mesh.surface_set_material(idx, materials[key])
		else:
			push_warning("LowPoly: no material for key '%s'" % key)
	return mesh
