shader_type canvas_item;

uniform vec3 color: source_color = vec3(0.381, 0.668, 0.831);
uniform float speed: hint_range(0.01, 10.0, 0.01) = 0.5;
uniform float density: hint_range(1.0, 500.0, 1.0) = 200.0;
uniform float compression: hint_range(0.1, 1.0, 0.01) = 0.15;
uniform float trail_size: hint_range(5.0, 100.0, 0.1) = 10.0;
uniform float brightness: hint_range(0.1, 10.0, 0.1) = 5.0;
uniform float center_size: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float center_edge: hint_range(0.0, 1.0, 0.01) = 0.05;

void fragment() {
	vec2 uv = vec2(SCREEN_UV.x - 0.5, SCREEN_UV.y - 0.375);
	float time = TIME * speed;
	float circle = smoothstep(center_size - center_edge, center_size, length(uv));
	float dist = length(uv);
	float angle = atan(uv.x, uv.y);
	uv = vec2(angle / PI, 1.0 / dist);
	uv.x *= density;
	vec2 duv = vec2(floor(uv.x), uv.y) * compression;
	float offset = sin(duv.x);
	float fall = cos(duv.x * 30.0);
	float trail = mix(100.0, trail_size, fall);
	float drop = fract(duv.y + time * fall + offset) * trail;
	drop = 1.0 / drop;
	drop = smoothstep(0.0, 1.0, drop * drop);
	drop = sin(drop * PI) * fall * brightness;
	float shape = sin(fract(uv.x) * PI);
	drop *= shape * shape;
	COLOR = vec4(color * drop * circle, 1.0);
	//COLOR = vec4(UV.x, UV.y, 0.0, 1.0); // Red=X, Green=Y
}