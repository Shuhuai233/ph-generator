@tool
class_name gltf_exporter
extends RefCounted

var _config


func set_config(cm) -> void:
	_config = cm


func export_to_glb(node: Node3D, file_name: String) -> String:
	var export_dir = _config.export_dir if _config else "res://exports"
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(export_dir.replace("res://", "")):
		dir.make_dir_recursive(export_dir.replace("res://", ""))

	var path = export_dir.path_join(file_name + ".glb")
	if not path.ends_with(".glb"):
		path += ".glb"

	var gltf_doc = GLTFDocument.new()
	var gltf_state = GLTFState.new()

	gltf_state.set_handle_binary_image(GLTFState.HANDLE_BINARY_EMBED_AS_UNCOMPRESSED)

	var err = gltf_doc.append_from_scene(node, gltf_state)
	if err != OK:
		push_error("GLTF append_from_scene failed: " + str(err))
		return ""

	err = gltf_doc.write_to_filesystem(gltf_state, path)
	if err != OK:
		push_error("GLTF write_to_filesystem failed: " + str(err))
		return ""

	var abs_path = ProjectSettings.globalize_path(path)
	return abs_path
