shader_type canvas_item;

uniform sampler2D other_labels_texture;
uniform vec2 viewport_size;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color;
	// Convert to viewport coordinates
	vec2 viewport_pos = SCREEN_PIXEL_SIZE * FRAGCOORD.xy;
	vec2 other_uv = viewport_pos / viewport_size;
	// Check bounds more accurately
	if (other_uv.x >= 0.0 && other_uv.y >= 0.0 && other_uv.x <= 1.0 && other_uv.y <= 1.0) {
		vec4 other_color = texture(other_labels_texture, other_uv);
		// Only blend where both textures are visible
		if (tex_color.a > 0.1 && other_color.a > 0.1) {
			COLOR.a = 0.5 * tex_color.a; // Preserve original alpha
		}
	}
}