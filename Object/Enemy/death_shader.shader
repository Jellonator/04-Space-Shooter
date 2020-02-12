shader_type canvas_item;

uniform float death = 1.0;

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb = COLOR.rgb * death * death;
	if (death < 1.0) {
		uint x = uint(floor(UV.x / TEXTURE_PIXEL_SIZE.x));
		uint y = uint(floor(UV.y / TEXTURE_PIXEL_SIZE.y));
		uint seed = x * uint(5776) + y * uint(1057);
		float prob = rand_from_seed(seed);
		if (prob > death) {
			COLOR.a = 0.0;
		}
	}
}