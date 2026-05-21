extends SceneTree

const MeshBuilder = preload("res://addons/ph_generator/core/mesh_builder.gd")
const PresetLib = preload("res://addons/ph_generator/presets/library.gd")


func _initialize() -> void:
	print("=== BUILD GYM: Generating merged PH meshes and demo scene ===\n")

	# Ensure gym_meshes directory exists
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("gym_meshes"):
		dir.make_dir("gym_meshes")

	# Items: [preset_key, description, target_dims, label_zh]
	var items: Array = [
		["车", "轿车", Vector3(4, 1.8, 1.5), "Car"],
		["箱子", "木箱", Vector3(1, 1, 1), "Box"],
		["掩体", "混凝土掩体", Vector3(1.2, 0.8, 1.8), "Cover"],
		["门", "木门", Vector3(0.8, 0.08, 2.2), "Door"],
		["柱子", "石柱", Vector3(0.5, 0.5, 3), "Pillar"],
	]

	var mesh_files: Array[String] = [
		"res://gym_meshes/car_ph.res",
		"res://gym_meshes/box_ph.res",
		"res://gym_meshes/cover_ph.res",
		"res://gym_meshes/door_ph.res",
		"res://gym_meshes/pillar_ph.res",
	]

	for i in range(items.size()):
		var item = items[i]
		var preset_key: String = item[0]
		var description: String = item[1]
		var dims: Vector3 = item[2]

		var preset = PresetLib.get_preset(preset_key)
		var parsed = PresetLib._scale_preset(preset, dims, preset_key)
		parsed["description"] = description

		var merged = MeshBuilder.build_merged_mesh(parsed)
		if merged == null:
			push_error("Failed to build merged mesh for: " + preset_key)
			continue

		var save_path = mesh_files[i]
		var err = ResourceSaver.save(merged, save_path)
		if err != OK:
			push_error("Failed to save mesh: %s (err=%d)" % [save_path, err])
		else:
			print("  Saved: " + save_path + " (surfaces=" + str(merged.get_surface_count()) + ")")

	print("\n=== All merged meshes generated ===")
	_create_scene_text(items, mesh_files)
	print("\n=== DONE ===")
	quit(0)


func _create_scene_text(items: Array, mesh_files: Array[String]) -> void:
	var scene_text = '[gd_scene load_steps=15 format=3 uid="uid://demo_gym_v2"]\n\n'

	# StandardMaterial3D for whiteboxes (semi-transparent red) — index 1
	scene_text += '[sub_resource type="StandardMaterial3D" id="mat_whitebox"]\n'
	scene_text += 'albedo_color = Color(0.8, 0.3, 0.3, 0.5)\n'
	scene_text += 'transparency = 1\n\n'

	# StandardMaterial3D for merged PH gray — index 2
	scene_text += '[sub_resource type="StandardMaterial3D" id="mat_ph_gray"]\n'
	scene_text += 'albedo_color = Color(0.7, 0.7, 0.72, 1)\n'
	scene_text += 'roughness = 0.8\n'
	scene_text += 'metallic = 0.05\n\n'

	# StandardMaterial3D for floor — index 3
	scene_text += '[sub_resource type="StandardMaterial3D" id="mat_floor"]\n'
	scene_text += 'albedo_color = Color(0.25, 0.25, 0.28, 1)\n'
	scene_text += 'roughness = 0.95\n\n'

	# PlaneMesh for floor — index 4
	scene_text += '[sub_resource type="PlaneMesh" id="plane_floor"]\n'
	scene_text += 'size = Vector2(30, 30)\n\n'

	var sub_idx = 5
	var wb_box_ids: Array[String] = []
	var wb_box_dims: Array[Vector3] = []

	# BoxMesh sub_resources for whiteboxes
	for i in range(items.size()):
		var dims: Vector3 = items[i][2]
		scene_text += '[sub_resource type="BoxMesh" id="box_wb_%d"]\n' % i
		scene_text += 'size = Vector3(%.2f, %.3f, %.2f)\n\n' % [dims.x, dims.y, dims.z]
		wb_box_ids.append("box_wb_%d" % i)
		wb_box_dims.append(dims)
		sub_idx += 1

	# Load step count: 3 materials + 1 plane + 5 box meshes + 5 external mesh resources = 14
	# Actually external resources count in load_steps too
	# Let me recalculate: mat_whitebox(1) + mat_ph_gray(1) + mat_floor(1) + plane_floor(1) + 5 box_meshes(5) + 5 ext_resources(5) = 14
	# Update the header
	scene_text = scene_text.replace("load_steps=15", "load_steps=14")

	# External resources
	for i in range(mesh_files.size()):
		var file = mesh_files[i]
		var basename = file.get_file().get_basename()
		scene_text += '[ext_resource type="ArrayMesh" path="%s" id="%s"]\n\n' % [file, basename]

	# ── Root node ──
	scene_text += '[node name="GymMap" type="Node3D"]\n\n'

	# Floor
	scene_text += '[node name="Floor" type="MeshInstance3D" parent="."]\n'
	scene_text += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -2.5, -14, 0)\n'
	scene_text += 'mesh = SubResource("plane_floor")\n'
	scene_text += 'surface_material_override/0 = SubResource("mat_floor")\n\n'

	# Title
	scene_text += '[node name="Title" type="Label3D" parent="."]\n'
	scene_text += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -2.5, 8, 0)\n'
	scene_text += 'text = "GYM MAP — 白盒 vs AI PH 合并模式对比"\n'
	scene_text += 'font_size = 64\n'
	scene_text += 'billboard = 1\n'
	scene_text += 'pixel_size = 0.005\n\n'

	# Light
	scene_text += '[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]\n'
	scene_text += 'transform = Transform3D(0.866, -0.354, -0.354, 0.354, 0.933, -0.067, 0.354, -0.067, 0.933, 0, 10, 8)\n'
	scene_text += 'light_energy = 0.8\n\n'

	# Camera
	scene_text += '[node name="Camera3D" type="Camera3D" parent="."]\n'
	scene_text += 'transform = Transform3D(1, 0, 0, 0, 0.866, -0.5, 0, 0.5, 0.866, 0, 0, 15)\n\n'

	# ── 5 pairs ──
	var y_positions: Array = [0.0, -3.0, -6.0, -9.0, -12.0]

	for i in range(items.size()):
		var item = items[i]
		var dims: Vector3 = item[2]
		var label_zh: String = item[3]
		var y_pos: float = y_positions[i]
		var mesh_file: String = mesh_files[i]
		var basename = mesh_file.get_file().get_basename()

		# LEFT: Whitebox
		scene_text += '[node name="%s_Whitebox" type="MeshInstance3D" parent="."]\n' % label_zh
		scene_text += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -8, %.3f, 0)\n' % (y_pos + dims.y / 2.0)
		scene_text += 'mesh = SubResource("box_wb_%d")\n' % i
		scene_text += 'surface_material_override/0 = SubResource("mat_whitebox")\n'

		var label_height = max(dims.y + 0.5, 1.5)
		scene_text += '[node name="Label" type="Label3D" parent="%s_Whitebox"]\n' % label_zh
		scene_text += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, %.2f, 0)\n' % label_height
		scene_text += 'text = "%s_Whitebox\\n(%.1f×%.2f×%.1f)"\n' % [label_zh, dims.x, dims.y, dims.z]
		scene_text += 'font_size = 24\n'
		scene_text += 'billboard = 1\n'
		scene_text += 'pixel_size = 0.01\n'
		scene_text += 'modulate = Color(1, 0.5, 0.5, 1)\n\n'

		# RIGHT: Merged PH
		scene_text += '[node name="PH_%s" type="Node3D" parent="."]\n' % label_zh
		scene_text += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3, %.2f, 0)\n' % y_pos

		scene_text += '[node name="MergedMesh" type="MeshInstance3D" parent="PH_%s"]\n' % label_zh
		scene_text += 'mesh = ExtResource("%s")\n' % basename
		scene_text += 'surface_material_override/0 = SubResource("mat_ph_gray")\n'

		scene_text += '[node name="Label" type="Label3D" parent="PH_%s"]\n' % label_zh
		scene_text += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.5, 0)\n'
		scene_text += 'text = "PH_%s\\n%s"\n' % [label_zh, label_zh]
		scene_text += 'font_size = 24\n'
		scene_text += 'billboard = 1\n'
		scene_text += 'pixel_size = 0.01\n'
		scene_text += 'modulate = Color(0.5, 1, 0.5, 1)\n\n'

	# Write the scene file
	var f = FileAccess.open("res://demo_gym.tscn", FileAccess.WRITE)
	f.store_string(scene_text)
	f.close()
	print("  demo_gym.tscn written successfully")
