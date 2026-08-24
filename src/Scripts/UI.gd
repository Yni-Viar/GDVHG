extends Control

@onready var human_mesh: MeshInstance3D = get_parent().get_node("VitruvianGame/mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_parse_blendshapes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _parse_blendshapes() -> void:
	var mesh: ArrayMesh = human_mesh.mesh
	for i in human_mesh.get_blend_shape_count():
		var blend_shape: String = mesh.get_blend_shape_name(i)
		var blend_shape_value: float = human_mesh.get_blend_shape_value(i)
		var hbox_container: HBoxContainer = HBoxContainer.new()
		$ScrollContainer/VBoxContainer/BlendShapes/VBoxContainer.add_child(hbox_container)
		var label: Label = Label.new()
		label.custom_minimum_size = Vector2(384.0, 0.0)
		label.text = blend_shape
		hbox_container.add_child(label)
		var slider: HSlider = HSlider.new()
		slider.custom_minimum_size = Vector2(96.0, 0.0)
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.015625
		slider.value = blend_shape_value
		slider.name = blend_shape
		hbox_container.add_child(slider)
		slider.drag_ended.connect(_on_slider_toggled.bind(i, slider.get_path()))

func _on_slider_toggled(value_changed: bool, blend_shape_index: int, button_path: String) -> void:
	if value_changed:
		human_mesh.set_blend_shape_value(blend_shape_index, get_node(button_path).value)

func _on_color_picker_button_color_changed(color: Color) -> void:
	var shader: Material = human_mesh.get_surface_override_material(5)
	if shader is ShaderMaterial:
		shader.set_shader_parameter("iris", color)
		human_mesh.set_surface_override_material(5, shader)
