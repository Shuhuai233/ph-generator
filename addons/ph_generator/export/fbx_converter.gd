@tool
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

	var py_cmd = _find_python()
	if py_cmd.is_empty():
		push_error("Python 未安装或不在 PATH 中")
		return ""

	var output = []
	var exit_code = OS.execute(py_cmd, [script_path, glb_path, fbx_path], output, true)
	var std_text = "".join(output).strip_edges()
	if exit_code != 0:
		push_error("FBX 转换失败 (exit %d): %s" % [exit_code, std_text])
		return ""
	if "Warning" in std_text or "ERROR" in std_text:
		push_warning(std_text)
	return fbx_path


func is_python_available() -> bool:
	return not _find_python().is_empty()


func _find_python() -> String:
	var candidates = ["py", "python", "python3"] if OS.get_name() == "Windows" else ["python3", "python"]
	for cmd in candidates:
		var output = []
		var ec = OS.execute(cmd, ["--version"], output, true)
		var ver = "".join(output).strip_edges()
		if ec == 0 and "Python" in ver:
			return cmd
	return ""


func _get_script_path() -> String:
	var script = "res://addons/ph_generator/scripts/glb2fbx.py"
	if FileAccess.file_exists(script):
		return ProjectSettings.globalize_path(script)
	push_error("glb2fbx.py not found at: " + script)
	return ""
