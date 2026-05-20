@tool
class_name fbx_converter
extends RefCounted

var _config


func set_config(cm) -> void:
	_config = cm


func convert_glb_to_fbx(glb_path: String) -> String:
	var script_path = _get_script_path()
	if script_path.is_empty():
		push_error("Python 转换脚本未找到: scripts/glb2fbx.py")
		return ""

	var fbx_path = glb_path.replace(".glb", ".fbx")

	var output = []
	var exit_code = OS.execute("python3", [script_path, glb_path, fbx_path], output, true)
	if exit_code != 0:
		var err = "".join(output)
		push_error("FBX 转换失败 (exit " + str(exit_code) + "): " + err)
		return ""

	return fbx_path


func is_python_available() -> bool:
	var output = []
	var ec = OS.execute("python3", ["--version"], output, true)
	return ec == 0


func _get_script_path() -> String:
	var global_script = "res://addons/ph_generator/scripts/glb2fbx.py"
	if FileAccess.file_exists(global_script):
		return ProjectSettings.globalize_path(global_script)

	var local_script = ProjectSettings.globalize_path("res://") + "addons/ph_generator/scripts/glb2fbx.py"
	if FileAccess.file_exists(local_script):
		return local_script

	return ""
