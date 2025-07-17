shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float force : hint_range(0.0, 0.1) = 0.025;
uniform float size : hint_range(0.0, 1.5) = 0.0;
uniform float thickness : hint_range(0.0, 1.0) = 0.05;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 stretchedUV = UV;
	//stretchedUV.y = 1.0 - stretchedUV.y;
	float ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 delta = stretchedUV - center;
	delta.x *= ratio;
	float distant = length(delta);
	//vec2 scaledUV = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	//scaledUV = vec2(scaledUV.x * 1.0, scaledUV.y * 1.0);
	//float mask = (1.0 - smoothstep(size - 0.1, size, length(scaledUV - center))) * smoothstep(size - thickness - 0.1, size - thickness, length(scaledUV - center));
	float mask = (1.0 - smoothstep(size - 0.1, size, distant)) * smoothstep(size - thickness - 0.1, size - thickness, distant);
	//vec2 disp = normalize(scaledUV - center) * force * mask;
	vec2 disp = normalize(stretchedUV - center) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
	//COLOR = vec4(scaledUV.x, scaledUV.y, 0.0, 1.0);
	//if (length(scaledUV - center) < 0.01) {
		//COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	//}
	//COLOR = vec4(vec3(mask), 1.0);
	//COLOR = vec4(scaledUV.x, scaledUV.y, 0.0, 1.0);
	
	//COLOR = vec4(stretchedUV.x, stretchedUV.y, 0.0, 1.0);
	
	//COLOR.rgb = vec3(mask);
}
