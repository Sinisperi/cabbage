shader_type canvas_item;

// This allows the shader to see what's on screen behind the crosshair
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // 1. Get the color of the screen at this exact pixel location
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // 2. Invert the RGB values (1.0 - color)
    // This makes white backgrounds show a black crosshair, and vice versa.
    vec3 inverted_color = 1.0 - screen_color.rgb;
    
    // 3. Apply the inverted color to the crosshair
	//COLOR.rgb = inverted_color;
	
    COLOR = vec4(inverted_color, COLOR.a);
}