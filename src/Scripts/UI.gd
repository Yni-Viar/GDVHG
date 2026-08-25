extends Control

@onready var human_mesh: MeshInstance3D = get_parent().get_node("VitruvianGame/mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001")
var bake_mesh: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match OS.get_name():
		"Android":
			get_parent().get_node("FileDialog").use_native_dialog = true
		"Web":
			$ScrollContainer/VBoxContainer/SaveHuman.queue_free()
			$ScrollContainer/VBoxContainer/BakeMesh.queue_free()
	
	_parse_blendshapes()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Adds blend shapes and other initialization
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

##Changes eye color, both on real texture and render texture
func _on_color_picker_button_color_changed(color: Color) -> void:
	get_parent().get_node("EyeViewport/TextureRect").material.set_shader_parameter("iris", color)
	var shader: Material = human_mesh.get_surface_override_material(5)
	get_parent().get_node("EyeViewport").view_count = 1
	await get_tree().process_frame
	await get_tree().process_frame
	get_parent().get_node("EyeViewport").view_count = 0
	if shader is ShaderMaterial:
		shader.set_shader_parameter("iris", color)
		human_mesh.set_surface_override_material(5, shader)


func _on_file_dialog_file_selected(path: String) -> void:
	# Create a copy, and then remove unnecessary shaders
	var gltf_scene_root_node: Node3D = get_parent().get_node("VitruvianGame").duplicate()
	if bake_mesh:
		gltf_scene_root_node.get_node("mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001").mesh = human_mesh.bake_mesh_from_current_blend_shape_mix()
		for i in range(human_mesh.mesh.get_surface_count()):
			gltf_scene_root_node.get_node("mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001").mesh.surface_set_material(i, human_mesh.mesh.surface_get_material(i))
	gltf_scene_root_node.get_node("mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001").set_surface_override_material(2, load("res://Assets/basemesh/mesh/aqueos_layer_eye.tres"))
	gltf_scene_root_node.get_node("mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001").set_surface_override_material(4, null)
	gltf_scene_root_node.get_node("mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001").set_surface_override_material(7, null)
	
	# Set baked skin texture
	get_parent().get_node("SkinViewport").view_count = 1
	await get_tree().process_frame
	await get_tree().process_frame
	var body_material: StandardMaterial3D = load("res://Assets/basemesh/mesh/body_default.tres")
	var texture: ImageTexture = ImageTexture.create_from_image(get_parent().get_node("SkinViewport").get_texture().get_image())
	body_material.albedo_texture = texture
	get_parent().get_node("SkinViewport").view_count = 0
	
	
	gltf_scene_root_node.get_node("mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001").set_surface_override_material(0, body_material)
	
	# Set baked eye texture
	var eye_material: StandardMaterial3D = load("res://Assets/basemesh/mesh/eye_default.tres")
	
	get_parent().get_node("EyeViewport").view_count = 1
	await get_tree().process_frame
	await get_tree().process_frame
	texture = ImageTexture.create_from_image(get_parent().get_node("EyeViewport").get_texture().get_image())
	get_parent().get_node("EyeViewport").view_count = 0
	eye_material.albedo_texture = texture
	gltf_scene_root_node.get_node("mixamo_vitruvian_001/Skeleton3D/cm_vitruvian_001").set_surface_override_material(5, eye_material)
	# Save a new glTF scene.
	var gltf_document_save := GLTFDocument.new()
	var gltf_state_save := GLTFState.new()
	gltf_document_save.append_from_scene(gltf_scene_root_node, gltf_state_save)
	# The file extension in the output `path` (`.gltf` or `.glb`) determines
	# whether the output uses text or binary format.
	# `GLTFDocument.generate_buffer()` is also available for saving to memory.
	gltf_document_save.write_to_filesystem(gltf_state_save, path)
	gltf_scene_root_node.queue_free()


func _on_bake_mesh_toggled(toggled_on: bool) -> void:
	bake_mesh = toggled_on


func _on_skin_color_drag_ended(value_changed: bool) -> void:
	if value_changed:
		get_parent().get_node("SkinViewport/TextureRect").material.set_shader_parameter("value", $ScrollContainer/VBoxContainer/SkinColor.value)
		get_parent().get_node("SkinViewport").view_count = 1
		await get_tree().process_frame
		await get_tree().process_frame
		var shader: Material = human_mesh.get_surface_override_material(0)
		var texture: ImageTexture = ImageTexture.create_from_image(get_parent().get_node("SkinViewport").get_texture().get_image())
		if shader is ShaderMaterial:
			shader.set_shader_parameter("texture_albedo", texture)
			human_mesh.set_surface_override_material(0, shader)
		get_parent().get_node("SkinViewport").view_count = 0


func _on_save_human_pressed() -> void:
	get_parent().get_node("FileDialog").show()


func _on_face_pressed() -> void:
	get_parent().get_node("Camera3D").global_position = get_parent().get_node("FaceMarker").global_position


func _on_body_pressed() -> void:
	get_parent().get_node("Camera3D").global_position = get_parent().get_node("BodyMarker").global_position

func _on_move_forward_button_down() -> void:
	get_parent().get_node("Camera3D")._w = true

func _on_move_forward_button_up() -> void:
	get_parent().get_node("Camera3D")._w = false
