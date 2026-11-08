shader_type canvas_item;

// PS2-style post effect applied to the low-resolution 3D view: colour banding with ordered (Bayer)
// dithering, desaturation + tint, film grain and a vignette. Runs at the LOW resolution grid, so every
// dither cell is one low-res pixel (the container upscales with nearest filtering).

uniform float enabled = 1.0;
uniform float levels = 32.0;            // colour levels per channel (PS2 16-bit colour ~ 32)
uniform float dither_strength = 1.0;
uniform float saturation = 0.85;
uniform float contrast = 1.05;
uniform vec3 tint : source_color = vec3(1.0);
uniform float grain = 0.045;
uniform float vignette = 0.35;

const float BAYER[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0);

void fragment() {
	vec2 size = vec2(textureSize(TEXTURE, 0));
	vec2 px = floor(UV * size);
	vec3 c = texture(TEXTURE, (px + 0.5) / size).rgb;
	if (enabled < 0.5) {
		COLOR = vec4(c, 1.0);
	} else {
		float l = dot(c, vec3(0.299, 0.587, 0.114));
		c = mix(vec3(l), c, saturation);
		c = (c - 0.5) * contrast + 0.5;
		c *= tint;

		int bx = int(mod(px.x, 4.0));
		int by = int(mod(px.y, 4.0));
		float b = BAYER[bx + 4 * by] / 16.0 - 0.5;
		c += b * dither_strength / levels;
		c = floor(c * (levels - 1.0) + 0.5) / (levels - 1.0);

		float n = fract(sin(dot(px + floor(TIME * 24.0) * 17.0, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
		c += n * grain;

		vec2 q = UV - 0.5;
		c *= clamp(1.0 - dot(q, q) * vignette * 2.2, 0.0, 1.0);
		COLOR = vec4(max(c, vec3(0.0)), 1.0);
	}
}
