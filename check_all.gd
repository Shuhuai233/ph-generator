extends SceneTree

func _initialize() -> void:
	print("=== CHECKING ALL ADDON SCRIPTS ===\n")

	var files = [
		"res://addons/ph_generator/plugin.gd",
		"res://addons/ph_generator/dock/main_dock.gd",
		"res://addons/ph_generator/core/ph_generator.gd",
		"res://addons/ph_generator/core/scene_builder.gd",
		"res://addons/ph_generator/core/mesh_builder.gd",
		"res://addons/ph_generator/core/material_db.gd",
		"res://addons/ph_generator/ai/llm_client.gd",
		"res://addons/ph_generator/ai/prompt_mgr.gd",
		"res://addons/ph_generator/ai/parser.gd",
		"res://addons/ph_generator/export/gltf_exporter.gd",
		"res://addons/ph_generator/export/fbx_converter.gd",
		"res://addons/ph_generator/config/config_manager.gd",
		"res://addons/ph_generator/config/config_dialog.gd",
		"res://addons/ph_generator/presets/library.gd",
		"res://build_gym.gd",
	]

	var failed = 0
	for f in files:
		var script = load(f)
		if script == null:
			print("[FAIL] ", f)
			failed += 1
		else:
			print("[ OK ] ", f)

	print("\n=== ", files.size() - failed, "/", files.size(), " loaded OK, ", failed, " failed ===")
	quit(0 if failed == 0 else 1)
