@tool
extends EditorScript

## Headless Editor-Mode Plugin Test
##
## Run with:
##   godot --editor --headless --script res://test_editor_mode.gd --quit
##
## This verifies that the PH Generator plugin loads correctly
## in the editor environment (with EditorPlugin lifecycle).
## Unlike headless game mode (SceneTree), editor mode initializes
## all enabled EditorPlugins and calls _enter_tree().

func _run() -> void:
	print("=".repeat(60))
	print("  HEADLESS EDITOR PLUGIN TEST")
	print("=".repeat(60))
	print()

	var all_ok := true
	var checks := 0
	var passed := 0

	# ── Check 1: EditorInterface is available ──────────────────────
	checks += 1
	var ei = get_editor_interface()
	if ei:
		print("[%2d] PASS - EditorInterface is available" % checks)
		passed += 1
	else:
		print("[%2d] FAIL - EditorInterface is null!" % checks)
		all_ok = false

	# ── Check 2: plugin.cfg exists ─────────────────────────────────
	checks += 1
	if FileAccess.file_exists("res://addons/ph_generator/plugin.cfg"):
		print("[%2d] PASS - plugin.cfg exists" % checks)
		passed += 1
	else:
		print("[%2d] FAIL - plugin.cfg missing!" % checks)
		all_ok = false

	# ── Check 3: plugin.gd loads ───────────────────────────────────
	checks += 1
	var plugin_script = load("res://addons/ph_generator/plugin.gd")
	if plugin_script:
		print("[%2d] PASS - plugin.gd parsed successfully" % checks)
		passed += 1
	else:
		print("[%2d] FAIL - plugin.gd could not be loaded!" % checks)
		all_ok = false

	# ── Check 4: Plugin instantiation ──────────────────────────────
	checks += 1
	var inst = plugin_script.new()
	if inst:
		print("[%2d] PASS - plugin.gd instantiated" % checks)
		passed += 1
		# Check that it's the right type
		if inst is EditorPlugin:
			print("       - extends EditorPlugin: YES")
		else:
			print("       - extends EditorPlugin: NO")
			all_ok = false
	else:
		print("[%2d] FAIL - plugin.gd could not be instantiated!" % checks)
		all_ok = false

	# ── Check 5: All 14 addon scripts load ─────────────────────────
	var addon_files = [
		"res://addons/ph_generator/core/mesh_builder.gd",
		"res://addons/ph_generator/core/material_db.gd",
		"res://addons/ph_generator/core/scene_builder.gd",
		"res://addons/ph_generator/core/ph_generator.gd",
		"res://addons/ph_generator/ai/parser.gd",
		"res://addons/ph_generator/ai/prompt_mgr.gd",
		"res://addons/ph_generator/ai/llm_client.gd",
		"res://addons/ph_generator/presets/library.gd",
		"res://addons/ph_generator/config/config_manager.gd",
		"res://addons/ph_generator/config/config_dialog.gd",
		"res://addons/ph_generator/dock/main_dock.gd",
		"res://addons/ph_generator/export/gltf_exporter.gd",
		"res://addons/ph_generator/export/fbx_converter.gd",
	]
	for f in addon_files:
		checks += 1
		var s = load(f)
		if s:
			print("[%2d] PASS - %s" % [checks, f.get_file()])
			passed += 1
		else:
			print("[%2d] FAIL - %s could not load!" % [checks, f.get_file()])
			all_ok = false

	# ── Check 6: Core modules instantiate ──────────────────────────
	var instantiable = [
		["MeshBuilder",   preload("res://addons/ph_generator/core/mesh_builder.gd")],
		["MaterialDB",    preload("res://addons/ph_generator/core/material_db.gd")],
		["Parser",        preload("res://addons/ph_generator/ai/parser.gd")],
		["ConfigManager", preload("res://addons/ph_generator/config/config_manager.gd")],
	]
	for pair in instantiable:
		checks += 1
		var obj = pair[1].new()
		if obj:
			print("[%2d] PASS - %s instantiated" % [checks, pair[0]])
			passed += 1
		else:
			print("[%2d] FAIL - %s could not instantiate!" % [checks, pair[0]])
			all_ok = false

	# ── Check 7: MeshBuilder produces geometry ─────────────────────
	checks += 1
	var mesh = preload("res://addons/ph_generator/core/mesh_builder.gd").build_box({"type": "box", "size": Vector3(2, 1, 1.5)})
	if mesh and mesh.get_surface_count() > 0:
		print("[%2d] PASS - MeshBuilder.build_box() works" % checks)
		passed += 1
	else:
		print("[%2d] FAIL - MeshBuilder.build_box() returned null!" % checks)
		all_ok = false

	# ── Results ────────────────────────────────────────────────────
	print()
	print("=".repeat(60))
	print("  RESULTS: %d/%d passed" % [passed, checks])
	var verdict = "ALL PASSED" if all_ok else "SOME FAILED"
	print("  VERDICT: %s" % verdict)
	print("=".repeat(60))

	# Exit with non-zero on failure for CI
	if not all_ok:
		print("ERROR: Plugin validation failed!")
	# EditorScript cannot call quit() directly in some Godot versions.
	# The --quit flag on the command line handles exit.
