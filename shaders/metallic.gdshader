shader_type canvas_item;

uniform float metallic : hint_range(0, 1) = 0.8;
uniform float roughness : hint_range(0, 1) = 0.2;
uniform vec4 base_color : source_color = vec4(0.7, 0.7, 0.7, 1.0);
uniform sampler2D normal_map;

void fragment() {
    // Get normal from normal map or default
    vec3 normal = texture(normal_map, SCREEN_UV).xyz * 2.0 - 1.0;
    normal = normalize(mix(vec3(0.0, 0.0, 1.0), normal, 0.8));
    
    // Light calculation
    vec3 light_dir = normalize(vec3(0.5, 0.5, 0.5));
    float diff = max(dot(normal, light_dir), 0.0);
    
    // Specular highlight
    vec3 view_dir = vec3(0.0, 0.0, 1.0);
    vec3 half_dir = normalize(light_dir + view_dir);
    float spec = pow(max(dot(normal, half_dir), 0.0), 
                   (1.0 - roughness) * 128.0);
    
    // Combine effects
    vec3 metallic_color = mix(base_color.rgb, vec3(1.0), metallic);
    COLOR = vec4(mix(diff * base_color.rgb, metallic_color, spec * metallic), base_color.a);
}