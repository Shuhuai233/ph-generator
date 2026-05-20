@tool
extends EditorScript

const SceneBuilder = preload("res://addons/ph_generator/core/scene_builder.gd")
const GLTFExporter = preload("res://addons/ph_generator/export/gltf_exporter.gd")
const ConfigManager = preload("res://addons/ph_generator/config/config_manager.gd")
const PresetLib = preload("res://addons/ph_generator/presets/library.gd")

func _run() -> void:
	print("=== PH Generator: Generating 5 Demo Examples ===\n")

	var examples = [
		{"desc": "轿车", "dims": Vector3(4.0, 1.8, 1.5), "key": "车"},
		{"desc": "木箱", "dims": Vector3(1.0, 1.0, 1.0), "key": "箱子"},
		{"desc": "混凝土掩体", "dims": Vector3(1.2, 0.8, 1.8), "key": "掩体"},
		{"desc": "木门", "dims": Vector3(0.8, 0.08, 2.2), "key": "门"},
		{"desc": "石柱", "dims": Vector3(0.5, 0.5, 3.0), "key": "柱子"},
	]

	var editor = get_editor_interface()
	var scene_root = editor.get_edited_scene_root()
	if scene_root == null:
		var root = Node3D.new()
		root.name = "MainScene"
		editor.get_resource_filesystem().scan()
		scene_root = root

	var sb = SceneBuilder.new()
	var exporter = GLTFExporter.new()
	var conf = ConfigManager.new()
	conf.load()
	exporter.set_config(conf)

	mkdir("res://exports/")

	var x_offset = -10.0
	for example in examples:
		print("Generating: ", example.desc)
		var preset = PresetLib.get_preset(example.key)
		var scaled = PresetLib._scale_preset(preset, example.dims, example.key)

		var node_name = "PH_" + example.desc
		var ph = sb.build_ph_root(scaled, scene_root, node_name)
		if ph:
			ph.owner = scene_root
			ph.position.x = x_offset
			print("  Created node: ", ph.name)
			var glb_path = exporter.export_to_glb(ph, example.key + "_ph")
			if glb_path:
				print("  Exported: ", glb_path)
		x_offset += 5.0

	print("\n=== Done! See exports/ folder for .glb files ===")


func mkdir(path: String) -> void:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(path.replace("res://", "")):
		dir.make_dir_recursive(path.replace("res://", ""))
