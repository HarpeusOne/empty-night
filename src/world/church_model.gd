class_name ChurchModel
extends RefCounted

## The parish church of Linia (Kosciol pw. Najswietszego Serca Pana Jezusa), modelled by eye from the reference
## photos in `src/key buildings/church/` and fitted to its OSM footprint (see docs/key-buildings/church.md).
##
## Local frame: s along the nave towards the FRONT (the tower), t across it, y up, origin at the centroid of the
## OSM footprint. Plan and rough heights come from the footprint (nave 15.7 m wide, whole church 41 m long); the
## tower and roof heights are estimates from the photos and are meant to be corrected by the author.
##
##   back (s = -21.7)  sanctuary (low hipped roof) | nave (tall gable roof) | front section (low gable roof)
##   with the tower rising from its front, the timber porch in front of the tower, two lean-tos at the sides.

const TILE := 3.0
const ROOF_TILE := 2.0
const UP := Vector3.UP
const BOTTOM := Color(0.60, 0.58, 0.55)
const WHITE := Color(1.0, 1.0, 1.0)

# materials (keys of BlockoutLevel.materials)
const PLASTER := "c_plaster"
const ROOF := "c_roof"             # plain grey sheet (the porch)
const ROOF_GREEN := "c_roof_green" # patinated green sheet: nave, front wings, side wings (photos of the sides)
const ROOF_DARK := "c_roof_dark"   # dark grey sheet: the rear block and the tower cap
const STONE := "c_stone"
const TIMBER := "c_timber"

# plan (metres, local frame)
const S_BACK := -21.9
const S_SANCT_END := -12.0
const S_NAVE_END := 9.8
const S_REAR_END := -15.6          # the wide rear room ends here (plan from the OSM footprint)
const HALF_REAR := 9.4
const S_FRONT := 15.3
const S_PORCH := 19.0
const HALF_NAVE := 7.85
const HALF_FRONT := 9.1
const HALF_TOWER := 3.0
const HALF_PORCH := 4.35

# heights (metres): the footprint gives no heights, these are read off the photos
const H_SANCT := 6.0               # the rear walls are as tall as the nave (photos of the rear, 2026-11-08)
const H_NAVE := 6.0
const NAVE_RISE := 5.9
const S_APEX := -16.95             # apex of the rear pyramid roof; the nave roof runs back to it
const PROJ := 3.4                  # the cross wall sticks out this far behind S_BACK (OSM footprint)
const HALF_PROJ := 4.4
const H_FRONT := 4.6
const H_SHAFT := 15.0

var lp: LowPoly
var origin := Vector2.ZERO        # (east, north) of the local origin
var u := Vector2.RIGHT            # +s as (east, north)
var v := Vector2.UP               # +t as (east, north)


func _init(p_lp: LowPoly, origin_en: Vector2, heading_deg: float) -> void:
	lp = p_lp
	origin = origin_en
	# The model is drawn with the tower at +s. The church stands the other way round (author's correction), so
	# the frame is turned 180 degrees about the middle of the main body (S_BACK..S_FRONT).
	var a := deg_to_rad(heading_deg)
	var u0 := Vector2(cos(a), sin(a))
	origin = origin_en + u0 * (S_BACK + S_FRONT)
	u = -u0
	v = Vector2(-u.y, u.x)


## Local (s, t, y) -> Godot position (x = east, z = -north).
func pt(s: float, t: float, y: float) -> Vector3:
	return Vector3(origin.x + u.x * s + v.x * t, y, -(origin.y + u.y * s + v.y * t))


## Local horizontal direction (ds, dt) -> Godot direction.
func dir(ds: float, dt: float) -> Vector3:
	return Vector3(u.x * ds + v.x * dt, 0.0, -(u.y * ds + v.y * dt))


# ------------------------------------------------------------------ primitives

## Vertical wall between two local points; `out` is the outward direction (local s, t). `off` pushes it outwards.
func wall(key: String, s0: float, t0: float, s1: float, t1: float, y0: float, y1: float, out: Vector2,
		off: float = 0.0, tile: float = TILE, c_bot: Color = BOTTOM, c_top: Color = WHITE) -> void:
	var o := out.normalized()
	var a := Vector2(s0, t0) + o * off
	var b := Vector2(s1, t1) + o * off
	var length := a.distance_to(b)
	var vt := (y1 - y0) / tile
	lp.quad_out(key, pt(a.x, a.y, y0), pt(b.x, b.y, y0), pt(b.x, b.y, y1), pt(a.x, a.y, y1),
		Vector2(0, vt), Vector2(length / tile, vt), Vector2(length / tile, 0), Vector2(0, 0), c_bot, c_top, dir(o.x, o.y))


## A textured rectangle in front of a wall; the whole texture is stretched over it.
func opening(key: String, s: float, t: float, y_center: float, w: float, h: float, out: Vector2, off: float = 0.04) -> void:
	var o := out.normalized()
	var c := pt(s + o.x * off, t + o.y * off, y_center)
	var o3 := dir(o.x, o.y)
	var right := Vector3(o3.z, 0.0, -o3.x).normalized() * (w * 0.5)   # the viewer's right when looking at the wall
	var up_half := Vector3(0.0, h * 0.5, 0.0)
	lp.quad_out(key, c - right - up_half, c + right - up_half, c + right + up_half, c - right + up_half,
		Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), WHITE, WHITE, o3)


## Box in local coordinates (four walls and a top).
func box(key: String, s0: float, s1: float, t0: float, t1: float, y0: float, y1: float, tile: float = TILE,
		top_key: String = "") -> void:
	wall(key, s0, t0, s1, t0, y0, y1, Vector2(0, -1), 0.0, tile)
	wall(key, s1, t0, s1, t1, y0, y1, Vector2(1, 0), 0.0, tile)
	wall(key, s1, t1, s0, t1, y0, y1, Vector2(0, 1), 0.0, tile)
	wall(key, s0, t1, s0, t0, y0, y1, Vector2(-1, 0), 0.0, tile)
	var tk := top_key if top_key != "" else key
	lp.quad_out(tk, pt(s0, t0, y1), pt(s1, t0, y1), pt(s1, t1, y1), pt(s0, t1, y1),
		Vector2(0, 0), Vector2((s1 - s0) / tile, 0), Vector2((s1 - s0) / tile, (t1 - t0) / tile), Vector2(0, (t1 - t0) / tile),
		WHITE, WHITE, UP)


## Triangle in a plane of constant s (a gable end), apex in the middle.
func gable_end(key: String, s: float, t0: float, t1: float, y_base: float, y_apex: float, out_sign: float) -> void:
	var tm := (t0 + t1) * 0.5
	var w := (t1 - t0) / TILE
	lp.tri_out(key, pt(s, t0, y_base), pt(s, t1, y_base), pt(s, tm, y_apex),
		Vector2(0, 0), Vector2(w, 0), Vector2(w * 0.5, -(y_apex - y_base) / TILE), BOTTOM, BOTTOM, WHITE, dir(out_sign, 0.0))


## Gable roof with the ridge along s; returns nothing, draws the two slopes.
func gable_roof(key: String, s0: float, s1: float, t0: float, t1: float, y_wall: float, rise: float,
		ov: float = 0.5, ov_end: float = 0.4) -> void:
	var tm := (t0 + t1) * 0.5
	var half := (t1 - t0) * 0.5
	var pitch := rise / half
	var ye := y_wall - ov * pitch
	var yr := y_wall + rise
	var slope := Vector2(half + ov, yr - ye).length()
	var ra := (s0 - ov_end) / ROOF_TILE
	var rb := (s1 + ov_end) / ROOF_TILE
	for side in [1.0, -1.0]:
		var te := tm + float(side) * (half + ov)
		var n := (UP + dir(0.0, float(side) * pitch)).normalized()
		lp.quad_out(key, pt(s0 - ov_end, te, ye), pt(s1 + ov_end, te, ye), pt(s1 + ov_end, tm, yr), pt(s0 - ov_end, tm, yr),
			Vector2(ra, slope / ROOF_TILE), Vector2(rb, slope / ROOF_TILE), Vector2(rb, 0), Vector2(ra, 0),
			Color(0.86, 0.86, 0.86), WHITE, n)
		# underside (without it the roof is invisible from below, e.g. from inside the porch)
		lp.quad_out(TIMBER, pt(s0 - ov_end, te, ye - 0.04), pt(s1 + ov_end, te, ye - 0.04), pt(s1 + ov_end, tm, yr - 0.04), pt(s0 - ov_end, tm, yr - 0.04),
			Vector2(ra, 0), Vector2(rb, 0), Vector2(rb, 1), Vector2(ra, 1), Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5), -n)


## Hipped roof (ridge along s, hips at both ends).
func hip_roof(key: String, s0: float, s1: float, t0: float, t1: float, y_wall: float, pitch: float, ov: float = 0.5) -> void:
	var tm := (t0 + t1) * 0.5
	var half := (t1 - t0) * 0.5
	var yr := y_wall + half * pitch
	var ye := y_wall - ov * pitch
	var rs0 := minf(s0 + half, (s0 + s1) * 0.5)
	var rs1 := maxf(s1 - half, (s0 + s1) * 0.5)
	var slope := Vector2(half + ov, yr - ye).length()
	for side in [1.0, -1.0]:
		var te := tm + float(side) * (half + ov)
		var n := (UP + dir(0.0, float(side) * pitch)).normalized()
		lp.quad_out(key, pt(s0 - ov, te, ye), pt(s1 + ov, te, ye), pt(rs1, tm, yr), pt(rs0, tm, yr),
			Vector2(s0 / ROOF_TILE, slope / ROOF_TILE), Vector2(s1 / ROOF_TILE, slope / ROOF_TILE),
			Vector2(rs1 / ROOF_TILE, 0), Vector2(rs0 / ROOF_TILE, 0), Color(0.86, 0.86, 0.86), WHITE, n)
	for end in [1.0, -1.0]:
		var se := (s1 + ov) if end > 0.0 else (s0 - ov)
		var rs := rs1 if end > 0.0 else rs0
		var n2 := (UP + dir(float(end) * pitch, 0.0)).normalized()
		lp.tri_out(key, pt(se, tm - half - ov, ye), pt(se, tm + half + ov, ye), pt(rs, tm, yr),
			Vector2(0, slope / ROOF_TILE), Vector2((half + ov) * 2.0 / ROOF_TILE, slope / ROOF_TILE), Vector2(half / ROOF_TILE, 0),
			Color(0.86, 0.86, 0.86), Color(0.86, 0.86, 0.86), WHITE, n2)


## Four-sided pyramid roof (the belfry cap).
func pyramid(key: String, sc: float, tc: float, half_s: float, half_t: float, y_base: float, height: float, ov: float) -> void:
	var apex := pt(sc, tc, y_base + height)
	var ys := y_base - ov * 0.5
	var corners := [
		Vector2(sc - half_s - ov, tc - half_t - ov), Vector2(sc + half_s + ov, tc - half_t - ov),
		Vector2(sc + half_s + ov, tc + half_t + ov), Vector2(sc - half_s - ov, tc + half_t + ov)]
	var outs := [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
	for i in range(4):
		var a: Vector2 = corners[i]
		var b: Vector2 = corners[(i + 1) % 4]
		var o: Vector2 = outs[i]
		var n := (UP * 1.4 + dir(o.x, o.y)).normalized()
		lp.tri_out(key, pt(a.x, a.y, ys), pt(b.x, b.y, ys), apex, Vector2(0, 2.0), Vector2(2.0, 2.0), Vector2(1.0, 0.0),
			Color(0.86, 0.86, 0.86), Color(0.86, 0.86, 0.86), WHITE, n)
	# the underside of the eaves, seen from below and from the tower walkway
	var c: Array = corners
	lp.quad_out(PLASTER, pt(c[0].x, c[0].y, ys), pt(c[1].x, c[1].y, ys), pt(c[2].x, c[2].y, ys), pt(c[3].x, c[3].y, ys),
		Vector2(0, 0), Vector2(2.5, 0), Vector2(2.5, 2.5), Vector2(0, 2.5), Color(0.6, 0.6, 0.6), Color(0.6, 0.6, 0.6), -UP)


## Lean-to roof sloping outwards from the wall at t_in to t_out.
func shed(key: String, s0: float, s1: float, t_in: float, t_out: float, y_in: float, y_out: float) -> void:
	var sign := 1.0 if t_out > t_in else -1.0
	var run := absf(t_out - t_in)
	var slope_len := Vector2(run, y_in - y_out).length()
	var n := (UP + dir(0.0, sign * (y_in - y_out) / run)).normalized()
	lp.quad_out(key, pt(s0, t_in, y_in), pt(s1, t_in, y_in), pt(s1, t_out, y_out), pt(s0, t_out, y_out),
		Vector2(s0 / ROOF_TILE, 0), Vector2(s1 / ROOF_TILE, 0), Vector2(s1 / ROOF_TILE, slope_len / ROOF_TILE),
		Vector2(s0 / ROOF_TILE, slope_len / ROOF_TILE), Color(0.86, 0.86, 0.86), WHITE, n)
	lp.quad_out(TIMBER, pt(s0, t_in, y_in - 0.04), pt(s1, t_in, y_in - 0.04), pt(s1, t_out, y_out - 0.04), pt(s0, t_out, y_out - 0.04),
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Color(0.5, 0.5, 0.5), Color(0.5, 0.5, 0.5), -n)


# ------------------------------------------------------------------ the church

func build() -> void:
	_sanctuary()
	_nave()
	_front_section()
	_lean_tos()
	_tower()
	_porch()
	_plinth()


func _sanctuary() -> void:
	# The rear room is as wide as the side wings (9.4 m, OSM footprint) and then narrows to the nave. Photos
	# (2026-11-08): its walls are as tall as the nave, plain on both sides, under a steep dark pyramid roof whose
	# top reaches the nave ridge. Behind it the projecting wall with the brown cross has a steep hipped roof of
	# its own, so from behind the roof shows two peaks with a valley. Tall wood-framed windows fill the corners
	# between the cross wall and the rear wall.
	var wr := HALF_REAR
	var w := HALF_NAVE
	for side in [1.0, -1.0]:
		var sd := float(side)
		wall(PLASTER, S_BACK, sd * HALF_PROJ, S_BACK, sd * wr, 0.0, H_SANCT, Vector2(-1, 0))
		wall(PLASTER, S_BACK, sd * wr, S_REAR_END, sd * wr, 0.0, H_SANCT, Vector2(0, sd))
		wall(PLASTER, S_REAR_END, sd * wr, S_REAR_END, sd * w, 0.0, H_SANCT, Vector2(1, 0))
		wall(PLASTER, S_REAR_END, sd * w, S_SANCT_END, sd * w, 0.0, H_SANCT, Vector2(0, sd))
		# the big window: nearly the whole corner wall, from the plinth up to under the eaves
		opening("c_window_grid", S_BACK, sd * (HALF_PROJ + wr) * 0.5, 3.2, 4.4, 4.8, Vector2(-1, 0))
	hip_roof(ROOF_DARK, S_BACK, S_SANCT_END, -wr, wr, H_SANCT, 0.66, 0.5)
	# the projecting cross wall
	var sb := S_BACK - PROJ
	var hp := HALF_PROJ
	wall(PLASTER, sb, -hp, sb, hp, 0.0, H_SANCT, Vector2(-1, 0))
	for side in [1.0, -1.0]:
		wall(PLASTER, S_BACK, float(side) * hp, sb, float(side) * hp, 0.0, H_SANCT, Vector2(0, float(side)))
	# its roof: hipped at the back, the ridge running forward into the pyramid roof
	hip_roof(ROOF_DARK, sb, -14.0, -hp, hp, H_SANCT, 1.2, 0.4)
	# the side door for the priest and the altar servers: on the left side of the cross wall, the only wall the
	# photos do not show
	opening("door", sb + PROJ * 0.5, -hp, 1.15, 1.1, 2.3, Vector2(0, -1))
	# the cross: brown wood, 4.1 m tall, standing proud of the wall (photo of the rear)
	var cs := sb - 0.09
	box("c_wood", cs, sb, -0.11, 0.11, 0.9, 5.0, 1.0)
	box("c_wood", cs, sb, -0.95, 0.95, 3.68, 3.9, 1.0)


func _nave() -> void:
	var w := HALF_NAVE
	var rise := NAVE_RISE
	for side in [1.0, -1.0]:
		wall(PLASTER, S_SANCT_END, float(side) * w, S_NAVE_END, float(side) * w, 0.0, H_NAVE, Vector2(0, float(side)))
		# two windows between the rear room and the side wing, three between the wing and the front (photos)
		for s in [-13.4, -10.4, -0.9, 2.4, 5.7]:
			opening("c_arch_white", s, float(side) * w, 3.0, 0.95, 2.8, Vector2(0, float(side)))
	wall(PLASTER, S_NAVE_END, -w, S_NAVE_END, w, 3.0, H_NAVE, Vector2(1, 0))
	gable_end(PLASTER, S_NAVE_END, -w, w, H_NAVE, H_NAVE + rise, 1.0)
	# the green roof runs back into the dark pyramid roof of the rear room and ends at its top (valleys)
	gable_roof(ROOF_GREEN, S_APEX, S_NAVE_END, -w, w, H_NAVE, rise, 0.5, 0.0)


func _front_section() -> void:
	# Low wings either side of the tower: mono-pitch roofs falling outwards from the tower (photos).
	var w := HALF_FRONT
	var y_t := 7.0                                       # roof height where it meets the tower
	var slope := (y_t - H_FRONT) / (w - HALF_TOWER)
	for side in [1.0, -1.0]:
		var sd := float(side)
		wall(PLASTER, S_NAVE_END, sd * w, S_FRONT, sd * w, 0.0, H_FRONT, Vector2(0, sd))
		var t0 := sd * HALF_TOWER
		var t1 := sd * w
		wall(PLASTER, S_FRONT, t0, S_FRONT, t1, 0.0, H_FRONT, Vector2(1, 0))
		lp.tri_out(PLASTER, pt(S_FRONT, t0, H_FRONT), pt(S_FRONT, t1, H_FRONT), pt(S_FRONT, t0, y_t),
			Vector2(0, 0), Vector2(2.0, 0), Vector2(0, -0.8), BOTTOM, BOTTOM, WHITE, dir(1, 0))
		opening("c_arch_brown", S_FRONT, sd * 6.1, 2.3, 0.95, 1.9, Vector2(1, 0))
		# the back of the wing beside the nave, up to the roof
		wall(PLASTER, S_NAVE_END, sd * HALF_NAVE, S_NAVE_END, sd * w, 0.0, H_FRONT, Vector2(-1, 0))
		var y_n := y_t - (HALF_NAVE - HALF_TOWER) * slope
		lp.tri_out(PLASTER, pt(S_NAVE_END, sd * HALF_NAVE, H_FRONT), pt(S_NAVE_END, sd * w, H_FRONT), pt(S_NAVE_END, sd * HALF_NAVE, y_n),
			Vector2(0, 0), Vector2(0.5, 0), Vector2(0, -0.3), BOTTOM, BOTTOM, WHITE, dir(-1, 0))
		shed(ROOF_GREEN, S_NAVE_END, S_FRONT + 0.3, t0, sd * (w + 0.5), y_t, H_FRONT - 0.5 * slope)
func _lean_tos() -> void:
	# the two side wings (OSM footprint: s -8.2 .. -3.4, 9.4 m out). Photos of both sides (2026-11-08): nearly as
	# tall as the nave wall, a green mono-pitch roof just under the nave eaves, a dark door in the middle of the
	# outer wall with a small arched window above it, on both sides.
	var s0 := -8.2
	var s1 := -3.4
	var t_out := HALF_REAR
	var h := 4.6
	for side in [1.0, -1.0]:
		var sd := float(side)
		var tt := sd * t_out
		wall(PLASTER, s0, tt, s1, tt, 0.0, h, Vector2(0, sd))
		wall(PLASTER, s0, sd * HALF_NAVE, s0, tt, 0.0, h, Vector2(-1, 0))
		wall(PLASTER, s1, sd * HALF_NAVE, s1, tt, 0.0, h, Vector2(1, 0))
		shed(ROOF_GREEN, s0 - 0.25, s1 + 0.25, sd * HALF_NAVE, sd * (t_out + 0.4), 5.5, h - 0.15)
		opening("door", (s0 + s1) * 0.5, tt, 1.2, 1.15, 2.4, Vector2(0, sd))
		opening("c_arch_white", (s0 + s1) * 0.5, tt, 3.3, 0.75, 1.05, Vector2(0, sd))
## A balustrade panel visible from both sides.
func rail(p0: Vector3, p1: Vector3, y0: float, y1: float, out: Vector3, length: float) -> void:
	for sgn in [1.0, -1.0]:
		lp.quad_out("c_rail", Vector3(p0.x, y0, p0.z), Vector3(p1.x, y0, p1.z), Vector3(p1.x, y1, p1.z), Vector3(p0.x, y1, p0.z),
			Vector2(0, 1), Vector2(length / 1.2, 1), Vector2(length / 1.2, 0), Vector2(0, 0), WHITE, WHITE, out * float(sgn))


func _tower() -> void:
	var s_a := 9.8
	var s_b := S_FRONT + 0.05                      # a few cm proud of the facade so nothing z-fights
	var w := HALF_TOWER
	box(PLASTER, s_a, s_b, -w, w, 0.0, H_SHAFT)
	# the lower part of the tower facade behind the porch is field stone (photos), full tower width
	wall(STONE, s_b, -w, s_b, w, 0.0, 5.2, Vector2(1, 0), 0.03, 1.5)
	# a cornice ring halfway up separates the lower tower from the clock stage
	box(PLASTER, s_a - 0.12, s_b + 0.12, -w - 0.12, w + 0.12, 8.5, 8.85)
	for t in [-1.45, 1.45]:
		opening("c_arch_louvre", s_b, t, 6.6, 1.0, 2.2, Vector2(1, 0))
	opening("c_clock", s_b, 0.0, 11.8, 1.9, 1.9, Vector2(1, 0))
	for side in [1.0, -1.0]:
		opening("c_clock", 12.6, float(side) * w, 11.8, 1.9, 1.9, Vector2(0, float(side)))
	# the belfry: a walkway with a balustrade, then the open stage with three arches on every side
	box(PLASTER, s_a - 0.3, s_b + 0.3, -w - 0.3, w + 0.3, H_SHAFT - 0.15, H_SHAFT + 0.05)
	var rail_off := 0.28
	var ry0 := H_SHAFT + 0.05
	var ry1 := H_SHAFT + 1.05
	var rl := w * 2.0 + rail_off * 2.0
	rail(pt(s_b + rail_off, -w - rail_off, 0), pt(s_b + rail_off, w + rail_off, 0), ry0, ry1, dir(1, 0), rl)
	rail(pt(s_a - rail_off, -w - rail_off, 0), pt(s_a - rail_off, w + rail_off, 0), ry0, ry1, dir(-1, 0), rl)
	for side in [1.0, -1.0]:
		var tt := float(side) * (w + rail_off)
		rail(pt(s_a - rail_off, tt, 0), pt(s_b + rail_off, tt, 0), ry0, ry1, dir(0, float(side)), s_b - s_a + rail_off * 2.0)
	var bs0 := s_a + 0.6
	var bs1 := s_b - 0.6
	var bt := w - 0.6
	var by0 := H_SHAFT + 0.05
	var by1 := H_SHAFT + 4.0
	# four belfry faces, the whole texture (three arches) on each
	var faces := [[bs1, -bt, bs1, bt, Vector2(1, 0)], [bs0, bt, bs0, -bt, Vector2(-1, 0)],
		[bs0, -bt, bs1, -bt, Vector2(0, -1)], [bs1, bt, bs0, bt, Vector2(0, 1)]]
	for f in faces:
		var o: Vector2 = f[4]
		lp.quad_out("c_belfry", pt(f[0], f[1], by0), pt(f[2], f[3], by0), pt(f[2], f[3], by1), pt(f[0], f[1], by1),
			Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0), WHITE, WHITE, dir(o.x, o.y))
	var sc := (bs0 + bs1) * 0.5                      # the belfry (and its apex) is centred here, not at s = 0
	pyramid(ROOF_DARK, sc, 0.0, (bs1 - bs0) * 0.5, bt, by1, 3.3, 0.7)
	# ball and cross on the top
	var top := by1 + 3.3
	box("c_black", sc - 0.18, sc + 0.18, -0.18, 0.18, top - 0.1, top + 0.35, 1.0)
	box("c_black", sc - 0.07, sc + 0.07, -0.07, 0.07, top + 0.3, top + 2.4, 1.0)
	box("c_black", sc - 0.07, sc + 0.07, -0.5, 0.5, top + 1.5, top + 1.65, 1.0)


func _porch() -> void:
	var w := HALF_PORCH
	var s0 := S_FRONT + 0.05
	var s1 := S_PORCH
	var y_wall := 3.5
	# the arched doorway in the tower wall: green doors in a stone portal
	opening("c_door", S_FRONT + 0.2, 0.0, 1.55, 2.3, 3.1, Vector2(1, 0), 0.0)
	for side in [1.0, -1.0]:
		for s in [s1 - 0.5, s0 + 0.9]:
			box(TIMBER, s - 0.2, s + 0.2, float(side) * (w - 0.4) - 0.2, float(side) * (w - 0.4) + 0.2, 0.0, y_wall - 0.2, 1.0)
		box(TIMBER, s0, s1, float(side) * (w - 0.4) - 0.15, float(side) * (w - 0.4) + 0.15, y_wall - 0.45, y_wall - 0.15, 1.0)
	box(TIMBER, s1 - 0.65, s1 - 0.35, -w + 0.2, w - 0.2, y_wall - 0.45, y_wall - 0.15, 1.0)
	var rise := 2.5
	gable_roof(ROOF, s0, s1, -w - 0.3, w + 0.3, y_wall, rise, 0.4, 0.5)
	# the timber truss in the gable end, facing the street
	var tm_y := y_wall + rise
	lp.tri_out(TIMBER, pt(s1 + 0.1, -w - 0.3, y_wall - 0.05), pt(s1 + 0.1, w + 0.3, y_wall - 0.05), pt(s1 + 0.1, 0.0, tm_y),
		Vector2(0, 0), Vector2(3, 0), Vector2(1.5, -1.5), WHITE, WHITE, WHITE, dir(1, 0))


func _plinth() -> void:
	# a field-stone band, 0.8 m high, round the walls
	var h := 0.8
	var o := 0.03
	var w := HALF_NAVE
	var wr := HALF_REAR
	wall(STONE, S_BACK, -wr, S_BACK, wr, 0.0, h, Vector2(-1, 0), o, 1.5)
	for side in [1.0, -1.0]:
		var sd := float(side)
		wall(STONE, S_BACK, sd * wr, S_REAR_END, sd * wr, 0.0, h, Vector2(0, sd), o, 1.5)
		wall(STONE, S_REAR_END, sd * wr, S_REAR_END, sd * w, 0.0, h, Vector2(1, 0), o, 1.5)
		wall(STONE, S_REAR_END, sd * w, -8.2, sd * w, 0.0, h, Vector2(0, sd), o, 1.5)
		wall(STONE, -3.4, sd * w, S_NAVE_END, sd * w, 0.0, h, Vector2(0, sd), o, 1.5)
		wall(STONE, -8.2, sd * wr, -3.4, sd * wr, 0.0, h, Vector2(0, sd), o, 1.5)
		wall(STONE, S_NAVE_END, sd * HALF_FRONT, S_FRONT, sd * HALF_FRONT, 0.0, h, Vector2(0, sd), o, 1.5)
		wall(STONE, S_FRONT, sd * HALF_TOWER, S_FRONT, sd * HALF_FRONT, 0.0, h, Vector2(1, 0), o, 1.5)
		wall(STONE, S_BACK, sd * 4.4, S_BACK - 3.4, sd * 4.4, 0.0, h, Vector2(0, sd), o, 1.5)
