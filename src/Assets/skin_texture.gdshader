// NOTE: Shader automatically converted from Godot Engine 4.7.1.stable's StandardMaterial3D.
//Made by Yni Viar
//Licensed under CC0

shader_type canvas_item;

uniform sampler2D skin_light : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D skin_dark : source_color, filter_linear_mipmap, repeat_enable;
uniform float value: hint_range(0.0, 1.0, 0.1);

void vertex() {
	
}

void fragment() {
	vec3 dark = texture(skin_dark, UV).rgb;
	vec3 light = texture(skin_light, UV).rgb;
	COLOR = vec4(mix(light, dark, value), 1.0);
}
