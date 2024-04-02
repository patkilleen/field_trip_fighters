shader_type canvas_item;

uniform vec2 Direction = vec2(1.0,0.0);// moving left by default
uniform float Speed = 0.02;
uniform float time = 0;
void fragment()
{
	//called each time pixel shown on screen

	COLOR = texture(TEXTURE,UV + (Direction*time*Speed));
	
	
}