shader_type canvas_item;

uniform float death = 1.0;

// This psuedo-random function is credited to The Book of Shaders by 
// Patricio Gonzalez Vivo & Jen Lowe.
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb = COLOR.rgb * death * death;
	if (death < 1.0) {
		uint x = uint(floor(UV.x / TEXTURE_PIXEL_SIZE.x));
		uint y = uint(floor(UV.y / TEXTURE_PIXEL_SIZE.y));
		float prob = rand(vec2(float(x), float(y)));
		if (prob > death) {
			COLOR.a = 0.0;
		}
	}
}