shader_type canvas_item;
render_mode unshaded;

uniform vec4 fade_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    color.rgb = mix(color.rgb, fade_color.rgb, opacity);
    COLOR = color;
}
