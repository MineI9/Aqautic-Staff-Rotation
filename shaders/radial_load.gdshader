shader_type canvas_item;

uniform float percentage: hint_range(0.0, 1.0) = 0.5;
uniform vec3 effect_color: source_color = vec3(0.416, 1.0, 1.0);

void fragment() {
	vec2 uv = vec2(SCREEN_UV.x - 0.5, SCREEN_UV.y - 0.37);
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	uv.x *= 1.0 / ratio;
	float dist2 = length(uv);
	float angle = atan(uv.x, uv.y);
	uv = vec2(angle / PI, 1.0 / dist2);
	float circle = smoothstep((sin(TIME) * 0.001) + 0.005, (sin(TIME) * 0.001) + 0.01, dist2);
	//vec4 main_tx = texture(TEXTURE, uv);
	float avg = (effect_color.r + effect_color.g + effect_color.b) / 3.0;
	//COLOR.a = effect_color.a;
	COLOR.rgb = circle * (effect_color * step(0.5 - percentage, 0.5 * uv.x) + vec3(avg) * step(0.5 * uv.x, 0.5 - percentage));
	//COLOR = vec4(uv.x, uv.y, 0.0, 1.0);
}
