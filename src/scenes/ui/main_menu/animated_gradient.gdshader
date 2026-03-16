shader_type canvas_item;
uniform sampler2D noise : repeat_enable;
uniform float speed: hint_range(0.0, 1.0, 0.1);
uniform vec2 direction;
void fragment() {
	vec4 noise_texture = texture(noise, UV + (TIME * speed * direction));
	COLOR.rgb = noise_texture.rgb;
}
