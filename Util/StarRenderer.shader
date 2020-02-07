shader_type particles;
render_mode keep_data;

uniform vec2 offset;

const vec2 PADDING = vec2(4.0, 4.0);
const vec2 SCREEN_SIZE = vec2(1024.0, 600.0);
const float MAX_PARTICLE_SIZE = 3.0;
const float MIN_PARTICLE_SIZE = 1.0;
const float MIN_DEPTH = 1.0;
const float MAX_DEPTH = 20.0;

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
		CUSTOM.z = sqrt(rand_from_seed(alt_seed)) * (MAX_DEPTH - MIN_DEPTH) + MIN_DEPTH;
		CUSTOM.x = rand_from_seed(alt_seed) * (SCREEN_SIZE.x + 2.0 * PADDING.x) * CUSTOM.z;
		CUSTOM.y = rand_from_seed(alt_seed) * (SCREEN_SIZE.y + 2.0 * PADDING.y) * CUSTOM.z;
	}
	COLOR = vec4(1, 1, 1, 0.85);
	float sizelerp = (CUSTOM.z - MIN_DEPTH) / (MAX_DEPTH - MIN_DEPTH);
	float size = mix(MIN_PARTICLE_SIZE, MAX_PARTICLE_SIZE, 1.0 - sizelerp) / 16.0;
	TRANSFORM[3].xy = mod((CUSTOM.xy + offset) / CUSTOM.z, SCREEN_SIZE + PADDING * 2.0) - PADDING;
	TRANSFORM[0].x = size;
	TRANSFORM[1].y = size;
}