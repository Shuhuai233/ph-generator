@tool
extends EditorPlugin

const MainDock = preload("res://addons/ph_generator/dock/main_dock.gd")
const PHGenerator = preload("res://addons/ph_generator/core/ph_generator.gd")

var _dock: Control = null
var _generator = null


func _enter_tree() -> void:
	print("[PH Generator] _enter_tree START")
	_generator = PHGenerator.new()
	print("[PH Generator] generator created")
	_generator.setup(self)
	print("[PH Generator] generator setup done")

	_dock = MainDock.new()
	print("[PH Generator] dock created")
	_dock.setup(_generator)
	print("[PH Generator] dock setup done")
	add_control_to_dock(DOCK_SLOT_RIGHT_UR, _dock)
	print("[PH Generator] dock added to editor")

	add_tool_menu_item("PH Generator Settings", _open_settings)
	print("[PH Generator] _enter_tree DONE")


func _exit_tree() -> void:
	if _dock:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null
	remove_tool_menu_item("PH Generator Settings")


func _open_settings() -> void:
	if _generator == null:
		return
	var config = _generator.get_config()
	const ConfigDialog = preload("res://addons/ph_generator/config/config_dialog.gd")
	var dialog = ConfigDialog.new()
	dialog.setup(config)
	var editor_root = get_editor_interface().get_base_control()
	editor_root.add_child(dialog)
	dialog.popup_centered()


func _handles(object: Object) -> bool:
	return object is MeshInstance3D or object is Node3D
