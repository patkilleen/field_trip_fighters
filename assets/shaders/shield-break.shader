shader_type canvas_item;

uniform sampler2D noise_tex_normal;
uniform sampler2D noise_tex;
uniform float progress : hint_range(0.0, 1.0);
uniform float strength = 1.0;
//https://godotshaders.com/shader/pixel-explosion/
// If your sprite doesn't have enough space and the explosion gets clipped, 
// you can uncomment this and adjust the scale
//void vertex() {
//	float scale = 3.0;
//	VERTEX *= scale;
//
//	UV *= scale;
//	UV -= (scale - 1.0) / 2.0;
//}

void fragment() {
	vec2 direction = texture(noise_tex_normal, UV).xy; // We're using normal map as direction
	direction -= 0.5; // Since our normal map is a texture, it ranges from 0.0 to 1.0...
	direction *= 2.0; // ...so we're going to make it range from -1.0 to 1.0.
	direction = direction * strength * progress;
	
	// UV for exploded texture
	vec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE; // Real texture size in pixels
	vec2 uv = floor(UV * tex_size) / (tex_size - 1.0); // Pixelate UV to snap pixels
	uv = uv - direction; // Distort UV
	
	// Texture with exploded UV
	vec4 tex = texture(TEXTURE, uv); 
	
	// Dissolve alpha
	float dissolve = texture(noise_tex, UV).x;
	dissolve = step(progress, dissolve);
	tex.a *= dissolve;
	
	// Border (in case the edge of your sprite stretches, otherwise you can remove this block)
	vec2 border_uv = uv * 2.0 - 1.0;
	border_uv = clamp(abs(border_uv), 0.0, 1.0);
	float border = max(border_uv.x, border_uv.y);
	border = ceil(1.0 - border);
	tex.a *= border;
	
	COLOR = tex;
}