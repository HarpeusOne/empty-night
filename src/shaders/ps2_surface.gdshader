shader_type spatial;
render_mode unshaded, cull_back;

// PS2-style surface: lighting is computed per VERTEX (sun + ambient + up to 4 point lights), the vertex colour
// is baked ambient occlusion / tint, fog is linear in view depth, and vertices snap to a coarse grid.
// Everything is "unshaded" because the lighting is done here; Godot's own lights are not used.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float emission_strength = 0.0;          // lit windows / lamp heads (texture colour added unlit)

uniform vec3 sun_dir = vec3(0.45, -0.7, -0.5);  // direction the light travels, world space
uniform vec3 sun_color : source_color = vec3(1.0);
uniform vec3 ambient_color : source_color = vec3(0.4);
uniform vec3 fog_color : source_color = vec3(0.6);
uniform float fog_start = 40.0;
uniform float fog_end = 220.0;

uniform vec2 snap_grid = vec2(0.0, 0.0);        // vertex snapping resolution; 0 = off (the wobble made roads swim; try 640x480 to bring it back)
// Snapping only below this depth. On a huge triangle (the 800 m ground) a vertex moved by a fraction of a
// pixel tilts the whole depth plane by tens of centimetres, so the far ground wins the depth test against the
// fine grid near the camera and the grass vanishes at some view angles. Far vertices therefore stay put.
uniform float snap_max_depth = 60.0;
uniform float affine_amount = 0.0;              // 0 = perspective-correct textures, 1 = PS1-style affine

// Up to four point lights: xyz world position, w = range / rgb = colour * energy.
// (Uniform arrays did not accept the values, so they are four separate uniforms.)
uniform vec4 pl_pos0 = vec4(0.0);
uniform vec4 pl_pos1 = vec4(0.0);
uniform vec4 pl_pos2 = vec4(0.0);
uniform vec4 pl_pos3 = vec4(0.0);
uniform vec4 pl_col0 = vec4(0.0);
uniform vec4 pl_col1 = vec4(0.0);
uniform vec4 pl_col2 = vec4(0.0);
uniform vec4 pl_col3 = vec4(0.0);

varying vec3 v_light;
varying vec3 v_uvw;

vec3 plight(vec4 pos, vec4 col, vec3 wp, vec3 wn) {
	vec3 d = pos.xyz - wp;
	float dist = length(d);
	float att = clamp(1.0 - dist / max(pos.w, 0.001), 0.0, 1.0);
	return col.rgb * att * att * max(dot(wn, d / max(dist, 0.001)), 0.0);
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 wn = normalize(mat3(MODEL_MATRIX) * NORMAL);

	float ndl = max(dot(wn, -normalize(sun_dir)), 0.0);
	vec3 light = ambient_color + sun_color * ndl;
	light += plight(pl_pos0, pl_col0, world_pos, wn);
	light += plight(pl_pos1, pl_col1, world_pos, wn);
	light += plight(pl_pos2, pl_col2, world_pos, wn);
	light += plight(pl_pos3, pl_col3, world_pos, wn);
	v_light = light * COLOR.rgb;

	vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec4 clip = PROJECTION_MATRIX * view_pos;
	v_uvw = vec3(UV * clip.w, clip.w);            // lets the fragment shader rebuild affine (non-perspective) UVs
	if (snap_grid.x > 0.0 && clip.w > 0.01 && clip.w < snap_max_depth) {
		vec2 half_res = snap_grid * 0.5;
		vec2 ndc = clip.xy / clip.w;
		ndc = round(ndc * half_res) / half_res;
		clip.xy = ndc * clip.w;
	}
	POSITION = clip;
}

void fragment() {
	vec2 uv_affine = v_uvw.xy / max(v_uvw.z, 0.0001);
	vec2 uv = mix(UV, uv_affine, affine_amount);
	vec4 tex = texture(albedo_tex, uv);
	vec3 col = tex.rgb * tint.rgb * v_light + tex.rgb * emission_strength;
	// Fog per pixel (smoother than per vertex, and exact on huge polygons such as the ground).
	float fog = clamp((-VERTEX.z - fog_start) / max(fog_end - fog_start, 0.001), 0.0, 1.0);
	ALBEDO = mix(col, fog_color, fog);
	ALPHA = tex.a;                              // cut-out textures (fence pickets); every other texture is opaque
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
