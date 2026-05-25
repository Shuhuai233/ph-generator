@tool
extends EditorPlugin

# ── Preload the core scripts ─────────────────────────────────────────
# If ANY of these fail, the plugin silently won't load.
# Check the Godot Output panel for "[PH Generator]" messages.

const MainDock = preload("res://addons/ph_generator/dock/main_dock.gd")
const PHGenerator = preload("res://addons/ph_generator/core/ph_generator.gd")

var _dock: Control = null
var _generator = null


func _init() -> void:
	print("[PH Generator] _init() — script instance created")


func _enter_tree() -> void:
	print("[PH Generator] _enter_tree() START")

	# Step 1: Create the core generator
	var step := 1
	print("[PH Generator]   step %d: creating PHGenerator..." % step)
	_generator = PHGenerator.new()
	if _generator == null:
		push_error("[PH Generator]   step %d: FAILED to create PHGenerator!" % step)
		return
	print("[PH Generator]   step %d: OK" % step)
	step += 1

	# Step 2: Set up the generator
	print("[PH Generator]   step %d: calling generator.setup()..." % step)
	_generator.setup(self)
	print("[PH Generator]   step %d: OK" % step)
	step += 1

	# Step 3: Create the dock
	print("[PH Generator]   step %d: creating MainDock..." % step)
	_dock = MainDock.new()
	if _dock == null:
		push_error("[PH Generator]   step %d: FAILED to create MainDock!" % step)
		return
	print("[PH Generator]   step %d: OK" % step)
	step += 1

	# Step 4: Set up the dock
	print("[PH Generator]   step %d: calling dock.setup()..." % step)
	_dock.setup(_generator)
	print("[PH Generator]   step %d: OK" % step)
	step += 1

	# Step 5: Add dock to editor
	print("[PH Generator]   step %d: add_control_to_dock()..." % step)
	add_control_to_dock(DOCK_SLOT_RIGHT_UR, _dock)
	print("[PH Generator]   step %d: OK" % step)
	step += 1

	# Step 6: Register settings menu
	add_tool_menu_item("PH Generator Settings", _open_settings)
	print("[PH Generator]   step %d: tool menu registered" % step)

	print("[PH Generator] _enter_tree() DONE — all %d steps passed" % step)


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
