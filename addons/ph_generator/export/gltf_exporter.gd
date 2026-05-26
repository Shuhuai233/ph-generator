@tool
extends RefCounted

var _config


func set_config(cm) -> void:
	_config = cm


func export_to_glb(node: Node3D, file_name: String) -> String:
	var export_dir = _config.export_dir if _config else "res://exports"

	if export_dir.begins_with("res://"):
		var rel_dir = export_dir.replace("res://", "")
		var dir = DirAccess.open("res://")
		if not dir.dir_exists(rel_dir):
			dir.make_dir_recursive(rel_dir)
	else:
		if not DirAccess.dir_exists_absolute(export_dir):
			DirAccess.make_dir_recursive_absolute(export_dir)

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
	if not FileAccess.file_exists(abs_path):
		push_error("GLTF 文件未成功创建: " + abs_path)
		return ""
	return abs_path
