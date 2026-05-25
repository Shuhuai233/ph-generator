extends SceneTree

## Smoke test plugin checker — verifies the smoke test plugin files
## are structurally correct. Run with:
##   godot --headless --script res://addons/ph_smoke_test/check_smoke.gd --quit

func _initialize() -> void:
	print("=".repeat(60))
	print("  SMOKE TEST PLUGIN VALIDATION")
	print("=".repeat(60))
	print()

	var all_ok := true
	var passed := 0
	var failed := 0

	var checks = [
		["plugin.cfg exists", func(): return FileAccess.file_exists("res://addons/ph_smoke_test/plugin.cfg")],
		["plugin.gd parses", func(): return load("res://addons/ph_smoke_test/plugin.gd") != null],
		["dock.gd parses", func(): return load("res://addons/ph_smoke_test/dock.gd") != null],
		["plugin.gd extends EditorPlugin", func(): 
			var s = load("res://addons/ph_smoke_test/plugin.gd").new()
			return s is EditorPlugin],
		["dock.gd extends Control", func():
			var s = load("res://addons/ph_smoke_test/dock.gd").new()
			return s is Control],
	]

	var num := 0
	for c in checks:
		num += 1
		var result = c[1].call()
		if result:
			passed += 1
			print("[%2d] PASS - %s" % [num, c[0]])
		else:
			failed += 1
			all_ok = false
			print("[%2d] FAIL - %s" % [num, c[0]])

	print()
	print("=".repeat(60))
	if all_ok:
		print("  SMOKE TEST: ALL PASSED (%d/%d)" % [passed, passed + failed])
	else:
		print("  SMOKE TEST: %d/%d FAILED" % [failed, passed + failed])
	print("=".repeat(60))
	quit(0 if all_ok else 1)
