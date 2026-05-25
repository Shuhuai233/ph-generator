@tool
extends EditorPlugin

## Minimal smoke-test plugin. If this dock shows but PH Generator
## doesn't, the issue is in the PH Generator code, not Godot.
##
## Usage:
##   1. Copy addons/ph_smoke_test/ into your project
##   2. Enable "PH Smoke Test" in Project Settings > Plugins
##   3. Check the dock on the right for "PH Generator is working"
##   4. Also enable "PH Generator" plugin to compare

const MainDock = preload("res://addons/ph_smoke_test/dock.gd")

var _dock: Control = null


func _enter_tree() -> void:
	print("[PH SmokeTest] _enter_tree() START")
	_dock = MainDock.new()
	if _dock == null:
		push_error("[PH SmokeTest] failed to create dock")
		return
	_dock.setup(self)
	add_control_to_dock(DOCK_SLOT_RIGHT_UR, _dock)
	print("[PH SmokeTest] dock added — you should see it in the editor")


func _exit_tree() -> void:
	if _dock:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null
