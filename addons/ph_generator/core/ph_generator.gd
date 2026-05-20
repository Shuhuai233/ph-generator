@tool
class_name ph_generator
extends RefCounted

const SceneBuilder = preload("res://addons/ph_generator/core/scene_builder.gd")
const GLTFExporter = preload("res://addons/ph_generator/export/gltf_exporter.gd")
const FBXConverter = preload("res://addons/ph_generator/export/fbx_converter.gd")
const ConfigManager = preload("res://addons/ph_generator/config/config_manager.gd")
const LLMClient = preload("res://addons/ph_generator/ai/llm_client.gd")
const PresetLibrary = preload("res://addons/ph_generator/presets/library.gd")

signal status_update(message: String)
signal ph_generated(node: Node3D)
signal ph_exported(glb_path: String, fbx_path: String)

var _config
var _scene_builder
var _gltf_exporter
var _fbx_converter
var _llm_client
var _editor_plugin: EditorPlugin

var _pending_description: String
var _pending_dimensions: Vector3


func setup(editor_plugin: EditorPlugin) -> void:
	_editor_plugin = editor_plugin
	_config = ConfigManager.new()
	_config.load()

	_scene_builder = SceneBuilder.new()
	_scene_builder.set_config(_config)

	_gltf_exporter = GLTFExporter.new()
	_gltf_exporter.set_config(_config)

	_fbx_converter = FBXConverter.new()
	_fbx_converter.set_config(_config)


func get_config():
	return _config


func request_generate(description: String, dimensions: Vector3) -> void:
	if description.is_empty():
		status_update.emit("错误: 请输入物件描述")
		return

	if _config.api_key.is_empty():
		status_update.emit("使用离线模式 - 从内置模板库生成...")
		_generate_from_preset(description, dimensions)
		status_update.emit("离线生成完成 (使用模板近似)")
		return

	_pending_description = description
	_pending_dimensions = dimensions
	status_update.emit("正在调用 AI 分析描述: " + description)

	if _llm_client == null:
		_llm_client = LLMClient.new()
	_llm_client.set_config(_config)
	_llm_client.response_received.connect(_on_llm_response)
	_llm_client.error_occurred.connect(_on_llm_error)
	_llm_client.request_ph_json(description, dimensions)


func _on_llm_response(parsed: Dictionary) -> void:
	status_update.emit("AI 解析完成: " + parsed.get("description", ""))
	_build_and_place(parsed)


func _on_llm_error(message: String) -> void:
	status_update.emit("AI 请求失败: " + message)
	status_update.emit("回退到离线模板模式...")
	_generate_from_preset(_pending_description, _pending_dimensions)


func _generate_from_preset(description: String, dimensions: Vector3) -> void:
	var parsed = PresetLibrary.find_best_match(description, dimensions)
	_build_and_place(parsed)


func _build_and_place(parsed: Dictionary) -> void:
	var scene_root = _editor_plugin.get_editor_interface().get_edited_scene_root()
	if scene_root == null:
		var scn = PackedScene.new()
		var root = Node3D.new()
		root.name = "MainScene"
		scn.pack(root)
		scn.take_over_path("res://main_scene.tscn")
		scene_root = root

	var ph_node = _scene_builder.build_ph_root(parsed, scene_root, "PH_" + parsed.get("description", "Generated"))
	if ph_node == null:
		status_update.emit("构建 PH 节点失败")
		return

	ph_generated.emit(ph_node)
	status_update.emit("PH 已生成到场景中: " + ph_node.name)


func export_glb(ph_node: Node3D, file_name: String = "") -> String:
	if file_name.is_empty():
		file_name = ph_node.name

	status_update.emit("导出 .glb: " + file_name)
	var glb_path = _gltf_exporter.export_to_glb(ph_node, file_name)

	if glb_path.is_empty():
		status_update.emit("导出 .glb 失败")
		return ""

	status_update.emit(".glb 导出成功: " + glb_path)

	var fbx_path = ""
	if _config.export_fbx:
		if _fbx_converter.is_python_available():
			status_update.emit("开始转换 FBX...")
			fbx_path = _fbx_converter.convert_glb_to_fbx(glb_path)
			if fbx_path:
				status_update.emit(".fbx 导出成功: " + fbx_path)
			else:
				status_update.emit("FBX 转换失败, 已保留 .glb")
		else:
			status_update.emit("Python 环境不可用, 跳过 FBX")

	ph_exported.emit(glb_path, fbx_path)
	return glb_path


func get_selected_node_bbox() -> Dictionary:
	var selection = _editor_plugin.get_editor_interface().get_selection()
	var nodes = selection.get_selected_nodes()
	if nodes.size() == 0:
		return {"dimensions": Vector3(1, 1, 1), "name": ""}

	var node = nodes[0]
	var name = node.name

	if node is MeshInstance3D and node.mesh:
		var aabb = node.mesh.get_aabb() if node.mesh else AABB()
		var size = aabb.size
		var scale = node.scale
		return {"dimensions": Vector3(size.x * scale.x, size.y * scale.y, size.z * scale.z), "name": name}

	var dims = Vector3(1, 1, 1)
	if node is Node3D:
		dims = get_node_extents(node)
	return {"dimensions": dims, "name": name}


static func get_node_extents(node: Node3D) -> Vector3:
	var max_point = Vector3.ZERO
	var min_point = Vector3.ZERO
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			var aabb = child.mesh.get_aabb()
			max_point = max_point.max(aabb.position + aabb.size * child.scale)
			min_point = min_point.min(aabb.position * child.scale)
	return (max_point - min_point).abs()
