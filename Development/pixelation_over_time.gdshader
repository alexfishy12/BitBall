
shader_type canvas_item;

uniform float max_pixel_size : hint_range(1.0, 50.0);
uniform float progress : hint_range(0.0, 1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV; // Get screen UV coordinates
	
   	vec2 screen_res = vec2(textureSize(SCREEN_TEXTURE, 0)); // Screen resolution
	
	// calculate pixel size based on elapsed time and duration
	
	float pixel_size = mix(1.0, max_pixel_size, progress); // Interpolate between 1 and max size
	
	// Ensure perfect restoration at the end of reverse mode
    if (pixel_size <= 1.01) {
        COLOR = texture(SCREEN_TEXTURE, uv);
		
    }
	else {
		// Convert UVs to centered coordinates
	    vec2 centered_uv = (uv - vec2(0.5)) * screen_res;

	    // Snap UVs to the nearest pixel grid
	    centered_uv = round(centered_uv / pixel_size) * pixel_size;

	    // Convert back to UV coordinates
	    vec2 pixelated_uv = (centered_uv / screen_res) + vec2(0.5);

	    // Sample from the center of the pixel block to avoid gaps
	    vec4 color = texture(SCREEN_TEXTURE, pixelated_uv + (0.5 / screen_res));
		
		// Fade to black. If reversed, fade from black
		color.rgb = mix(color.rgb, vec3(0.0), progress);

	    COLOR = color;	
	}
}