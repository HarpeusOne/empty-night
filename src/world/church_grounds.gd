class_name ChurchGrounds
extends RefCounted

## The FIRST layout of the church yard (paving, fences, crosses, benches, trees), expressed as map items for
## MapProps. It is only the starting point: once data/map/props.json exists the author's edits (MapEditor, F2)
## are the truth and this file is no longer used. Positions are a guess from photos and the OSM street.
## Church frame as in ChurchModel: s along the nave towards the tower, t across (viewer's right = +t at the front).

const S_FRONT_FENCE := 31.0
const S_BACK_FENCE := -34.0
const T_LEFT := -24.0
const T_RIGHT := 12.8
const GATE_HALF := 8.0


## `blocked`: Callable(Vector3 world position) -> bool, true where a building stands (items there are dropped).
static func default_items(m: ChurchModel, blocked: Callable) -> Array:
	var out: Array = []
	var ok := func(s: float, t: float) -> bool:
		return not (blocked.is_valid() and bool(blocked.call(m.pt(s, t, 0.0))))
	var line := func(type: String, pairs: Array, w: float = 0.0) -> void:
		var pts: Array = []
		for p in pairs:
			var v := m.pt(p[0], p[1], 0.0)
			pts.append([snappedf(v.x, 0.01), snappedf(v.z, 0.01)])
		out.append({"type": type, "pts": pts, "w": w})
	var point := func(type: String, s: float, t: float, face: Vector3, k: float = 1.0) -> void:
		if not ok.call(s, t):
			return
		var v := m.pt(s, t, 0.0)
		out.append({"type": type, "x": snappedf(v.x, 0.01), "z": snappedf(v.z, 0.01),
			"yaw": snappedf(atan2(face.x, face.z), 0.001), "s": k})
	var front := m.dir(1, 0)
	# paving
	line.call("path_cobble", [[15.4, 0.0], [S_FRONT_FENCE, 0.0]], 19.6)
	line.call("path_cobble", [[S_FRONT_FENCE, 0.0], [44.0, 0.0]], 2.0 * GATE_HALF)
	line.call("path_cobble", [[-22.0, -10.8], [15.4, -10.8]], 2.4)
	line.call("path_cobble", [[-22.0, 10.8], [15.4, 10.8]], 2.4)
	line.call("path_cobble", [[-5.8, 12.0], [-5.8, 14.3]], 2.8)
	# fences: brick at the front, field stone at the sides and back
	line.call("fence_brick", [[S_FRONT_FENCE, -GATE_HALF], [S_FRONT_FENCE, T_LEFT]])
	line.call("fence_brick", [[S_FRONT_FENCE, GATE_HALF], [S_FRONT_FENCE, T_RIGHT]])
	line.call("fence_stone", [[S_FRONT_FENCE, T_LEFT], [S_BACK_FENCE, T_LEFT], [S_BACK_FENCE, T_RIGHT], [-7.2, T_RIGHT]])
	line.call("fence_stone", [[-4.4, T_RIGHT], [S_FRONT_FENCE, T_RIGHT]])
	line.call("hedge", [[15.0, 12.3], [29.0, 12.3]])
	line.call("hedge", [[-33.2, -22.0], [-33.2, 10.0]])
	# objects
	point.call("cross_wood", 24.5, -11.5, front, 1.0)
	point.call("cross_iron", 25.5, 10.5, front, 1.0)
	point.call("shrine", 10.0, -20.0, front, 1.0)
	for b in [[23.0, -8.6], [27.0, -8.6], [23.0, 8.6], [27.0, 8.6]]:
		point.call("bench", b[0], b[1], m.dir(0, -signf(b[1])), 1.0)
	point.call("bench", 4.0, -12.4, m.dir(0, -1), 1.0)
	point.call("bench", -12.0, 11.3, m.dir(0, -1), 1.0)
	for c in [[21.0, -15.0, 1.4], [18.0, -18.0, 1.1], [30.0, -21.0, 1.2], [-30.0, -18.0, 1.2], [-31.0, 4.0, 1.1]]:
		point.call("conifer", c[0], c[1], front, c[2])
	point.call("leafy", 21.0, 11.2, front, 1.0)
	point.call("leafy", -14.0, -20.5, front, 0.9)
	return out
