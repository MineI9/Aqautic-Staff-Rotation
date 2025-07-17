shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform sampler2D noise3 : repeat_enable;
uniform sampler2D noise4 : repeat_enable;
uniform vec2 scroll1 = vec2(-0.025, 0.01);
uniform vec2 scroll2 = vec2(-0.01, -0.025);
uniform vec2 scroll3 = vec2(0.025, -0.01);
uniform vec2 scroll4 = vec2(0.01, 0.025);
uniform float distortion_strength : hint_range(-1, 1) = 0.5;
uniform vec4 tone_color : source_color = vec4(0.171, 0.627, 0.842, 1.0);
uniform vec4 top_color : source_color = vec4(0.598, 0.903, 0.989, 1.0);
uniform float light_start : hint_range(0.0, 1.0) = 0.05;
uniform float light_end : hint_range(0.0, 1.0) = 0.10;

uniform vec2 color_scroll = vec2(0.5, 0.5);
uniform float color_start : hint_range(0.0, 50.0) = 10.0;
uniform float color_end : hint_range(0.0, 50.0) = 50.0;
uniform sampler2D color_gradient;
uniform float gradient_scale : hint_range(0.1, 10.0) = 1.0;
uniform bool use_sine_wave = true;
uniform float sine_speed : hint_range(0.1, 5.0) = 1.0;
uniform float speed : hint_range(0.1, 5.0) = 1.0;
uniform vec4 mid_color : source_color = vec4(0.043, 0.46, 0.79, 1.0);
uniform float mid_color_start : hint_range(0.0, 1.0) = 0.0;
uniform float mid_color_end : hint_range(0.0, 1.0) = 0.05;
uniform float color_threshold : hint_range(0.0, 1.0) = 0.1; // When to blend
uniform vec4 low_color : source_color = vec4(0.0, 0.0, 0.54, 1.0);
uniform vec4 high_color : source_color = vec4(0.318, 0.524, 0.991, 1.0);

//void vertex() {
	// Called for every vertex the material is visible on.
//}

void fragment() {
	// Regular Stuff
	float depth = 0.25 * texture(noise1, UV + scroll1 * TIME).r * texture(noise2, UV + scroll2 * TIME).r * texture(noise3, UV + scroll3 * TIME).r * texture(noise4, UV + scroll4 * TIME).r;
	//depth = pow(depth, 1.0);
	//depth = mix(0.0, 1.0, depth);
	//vec4 noise_col = texture(noise1, UV + scroll1 * TIME);
	vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV + distortion_strength * vec2(depth));
	vec4 top_light = smoothstep(light_start, light_end, depth) * top_color;
	vec4 mid_light = smoothstep(mid_color_start, mid_color_end, depth) * mid_color;
	//COLOR = screen_col * tone_color + top_light;
	//vec4 new_tone_color = vec4(tone_color.r, tone_color.g, tone_color.b + smoothstep(color_start, color_end, TIME), 1.0);
	float gradient_pos = fract(TIME * speed);
	if (use_sine_wave) {
		gradient_pos = (sin(TIME * sine_speed) + 1.0) / 2.0;
	}
	vec4 color = texture(color_gradient, vec2(gradient_pos, 0.0));
	//float moving_pos = UV.x * gradient_scale + TIME;
	//moving_pos = fract(moving_pos);
	//vec4 color = texture(color_gradient, vec2(moving_pos, 0.0));
	//COLOR = 0.1 * color + screen_col * tone_color + mid_light + top_light;
	// Color mapping
    if (depth < color_threshold) {
        // Blend from dark blue to light blue in the dark areas
        float t = smoothstep(0.0, color_threshold, depth);
        color = mix(high_color, low_color, t);
    } else {
        // Keep original noise in brighter areas (white)
        color = vec4(depth);
    }
	COLOR = 0.1 * color + screen_col * tone_color + mid_light + top_light;
	COLOR.a = 1.0; // cap alpha
	
	//COLOR = vec4(UV.x, UV.y, 0.0, 1.0); // Red=X, Green=Y
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
