shader_type canvas_item;

uniform float radius;

// This psuedo-random function is credited to The Book of Shaders by 
// Patricio Gonzalez Vivo & Jen Lowe.
// Generates a float between 0 and 1.
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	float x = rand(UV + vec2(100, 0)) * 8.0 - 4.0;
	float y = rand(UV + vec2(0, 100)) * 8.0 - 4.0;
	vec2 v = round((vec2(x, y) + (UV / TEXTURE_PIXEL_SIZE)) / 8.0);
	float r = radius - rand(v) * 4.0;
	vec2 center = vec2(0.5, 0.5) / TEXTURE_PIXEL_SIZE;
	float dis = distance(center, UV / TEXTURE_PIXEL_SIZE);
	if (abs(dis - r + 2.0) < 2.0) {
		COLOR = vec4(248.0, 56.0, 0.0, 256.0) / 256.0;
	} else if (dis < r) {
		COLOR = texture(TEXTURE, UV);
	} else {
		COLOR = vec4(0, 0, 0, 0);
	}
}