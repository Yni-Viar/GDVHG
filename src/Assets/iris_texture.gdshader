// NOTE: Shader automatically converted from Godot Engine 4.7.1.stable's StandardMaterial3D.
//Made by Yni Viar
//Licensed under CC0

shader_type canvas_item;

uniform vec3 iris : source_color = vec3(0.9, 0.6, 0.3);
uniform sampler2D texture_iris : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	
}

void fragment() {

	vec4 iris_tex = texture(texture_iris, UV);

	COLOR = vec4(iris_tex.r * iris, 1.0);
}
