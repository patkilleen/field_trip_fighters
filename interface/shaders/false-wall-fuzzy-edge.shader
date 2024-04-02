shader_type canvas_item;

uniform float strength = 4.0;
uniform sampler2D noise;
uniform float time=0;
void fragment() {
	COLOR = texture(TEXTURE,UV);
	//float noise_value = texture( noise, vec2(fract(TIME), UV.y) ).r;
	float noise_value = texture( noise, vec2(fract(time), UV.y) ).r;
	if (COLOR.a == 0.0) {
		float dist_to_mid = abs(UV.x - 0.5) * 2.0;
		COLOR = vec4(1.0, 1.0, 1.0, strength * noise_value * (1.0 - dist_to_mid) * (1.0 - dist_to_mid) );
	}
}