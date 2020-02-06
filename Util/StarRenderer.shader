shader_type particles;
render_mode keep_data;

uniform vec2 offset;

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

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex() {
	uint base_number = uint(INDEX);
	uint alt_seed = hash(base_number + uint(2) + RANDOM_SEED);
	if (RESTART) {
		CUSTOM.z = sqrt(rand_from_seed(alt_seed)) * 20.0 + 1.0;
		CUSTOM.x = rand_from_seed(alt_seed) * 1024.0 * CUSTOM.z;
		CUSTOM.y = rand_from_seed(alt_seed) * 600.0 * CUSTOM.z;
	}
	COLOR = vec4(1, 1, 1, 0.85);
	float sizelerp = (CUSTOM.z - 1.0) / (20.0 - 1.0);
	float size = mix(1.0, 2.0, 1.0 - sizelerp);
	TRANSFORM[3].xy = mod((CUSTOM.xy + offset) / CUSTOM.z, vec2(1024.0, 600.0));
	TRANSFORM[0].x = size;
	TRANSFORM[1].y = size;
}