//shader_type canvas_item;
//
//uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
//
//uniform int samples = 35;
//uniform int lod = 2;
//uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
//
//float gaussian(vec2 i, float sigma) {
	//return exp(-0.5 * dot(i /= sigma, i)) / (6.28 * sigma * sigma);
//}
//
//vec4 blur(sampler2D text, vec2 uv, vec2 pixel_size) {
	//vec4 original_color = vec4(0.0);
	//
	//// the spread of the blur based on the number of samples.
	//float sigma = float(samples) * 0.25;
//
	//int sLOD = 1 << lod;
	//int s = samples / sLOD;
//
	//for (int i = 0; i < s * s; i++) {
		//vec2 offset = vec2(float(i % s), float(i / s)) * float(sLOD) - float(samples) / 2.0;
		//
		//// Accumulate the color from the texture at the calculated offset
		//// weighted by the gaussian function
		//original_color += gaussian(offset, sigma) * textureLod(text, uv + pixel_size * offset, float(lod));
	//}
//
	//// Normalize the final color by the accumulated alpha to prevent darkening + a check to prevent division by zero if fully transparent
	//return original_color.a > 0.0 ? original_color / original_color.a : vec4(0.0);
//}
//
//void fragment() {
	//vec4 blurred_color = blur(screen_texture, SCREEN_UV, SCREEN_PIXEL_SIZE);
	//vec3 mixed_rgb = mix(blurred_color.rgb, tint_color.rgb, tint_color.a);
	//COLOR = vec4(mixed_rgb, blurred_color.a);
//}

shader_type canvas_item;
// Hi! This is my first shader, so maybe its not the best at performance, but it makes the job.
//
// Used the following sites to know how the gaussian blur works:
// https://en.wikipedia.org/wiki/Gaussian_blur
// https://www.w3.org/Talks/2012/0125-HTML-Tehran/Gaussian.xhtml <- Helped a lot!



uniform sampler2D SCREEN_TEXTURE: hint_screen_texture,repeat_disable, filter_nearest;
uniform float sigma: hint_range(0.1, 20.0) = 3.3; // Limited to 20 because of performance, if you want feel free to break it.


float gaussianDistribution(float x, float STD){ // STD stands for standard deviation
	return exp(-(x*x)/(2.*STD*STD))/(sqrt(2.*PI)*STD);
}

vec3 gaussianblur(sampler2D sampler, vec2 pos, vec2 pixel_size, float sigmaUsed, int radius){
    vec3 blurredPixel = vec3(0.0);
    float total_weight = 0.0;
	// Loop over the radius (tecnically its a square)
    for(int i = -radius ; i <= radius; i++){ 
        for(int j = -radius; j <= radius; j++){
			// Calculate the offset from the current pixel
			vec2 offset = vec2(float(i), float(j))*pixel_size;
			vec2 changedPos = pos + offset;        
			
			// Calculate the weight based on the Gaussian distribution multiplying both dimentions (how far are X and Y form the center (pos))
			float weight = gaussianDistribution(float(i), sigmaUsed)*gaussianDistribution(float(j), sigmaUsed);
			// Add the weighted color value to the blurred pixel
			blurredPixel += texture(SCREEN_TEXTURE, changedPos).rgb * weight;
			total_weight += weight;
        }
    }
	// Normalize the blurred pixel color by the total weight
	blurredPixel/=total_weight;
    return blurredPixel;
}
void fragment() {
    vec3 PixelBlurred = gaussianblur(SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE, sigma, int(round(3.0 * sigma)));
    // The radius is 3*Sigma because it is the point where the Gaussian weight is near zero.
    COLOR = vec4(PixelBlurred, 1.);
}
