shader_type canvas_item;

uniform sampler2D mask;
uniform vec2 offset = vec2(0, 0);

void fragment() {
	vec2 newuv = UV + offset * TEXTURE_PIXEL_SIZE;
	COLOR = texture(TEXTURE, newuv);
	COLOR.a = COLOR.a * texture(mask, UV).a;
}