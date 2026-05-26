extends SceneTree

const MeshBuilder = preload("res://addons/ph_generator/core/mesh_builder.gd")
const PresetLib = preload("res://addons/ph_generator/presets/library.gd")


# ─── Object definitions ────────────────────────────────────────────────
# Each object: {key, label_zh, label_en, target_dims, row, col, blocks}
# blocks: Array of {name, pos:Vector3, size:Vector3}
# pos/size in Godot coords (X=right, Y=up, Z=forward)

func _define_objects() -> Array:
	return [
		# Row 0
		{
			"key": "车", "label_zh": "轿车", "label_en": "Car",
			"target": Vector3(4.0, 1.8, 1.5), "row": 0, "col": 0,
			"blocks": [
				{"name":"body", "pos":Vector3(0, 0.6, 0), "size":Vector3(4.0, 1.2, 1.5)},
				{"name":"cabin", "pos":Vector3(-0.3, 1.5, 0), "size":Vector3(2.0, 0.6, 1.3)},
				{"name":"wheel_fl", "pos":Vector3(-1.2, 0.15, 0.7), "size":Vector3(0.6, 0.3, 0.3)},
				{"name":"wheel_fr", "pos":Vector3(-1.2, 0.15, -0.7), "size":Vector3(0.6, 0.3, 0.3)},
				{"name":"wheel_rl", "pos":Vector3(1.2, 0.15, 0.7), "size":Vector3(0.6, 0.3, 0.3)},
				{"name":"wheel_rr", "pos":Vector3(1.2, 0.15, -0.7), "size":Vector3(0.6, 0.3, 0.3)},
			]
		},
		{
			"key": "箱子", "label_zh": "木箱", "label_en": "Crate",
			"target": Vector3(1.0, 1.0, 1.0), "row": 0, "col": 1,
			"blocks": [
				{"name":"body", "pos":Vector3(0, 0.5, 0), "size":Vector3(1.0, 1.0, 1.0)},
				{"name":"lid", "pos":Vector3(0, 1.0, 0), "size":Vector3(1.0, 0.05, 1.0)},
			]
		},
		{
			"key": "掩体", "label_zh": "掩体", "label_en": "Cover",
			"target": Vector3(1.2, 0.8, 1.8), "row": 0, "col": 2,
			"blocks": [
				{"name":"body", "pos":Vector3(0, 0.5, 0), "size":Vector3(1.2, 0.8, 1.8)},
				{"name":"top", "pos":Vector3(0, 1.05, 0), "size":Vector3(1.0, 0.3, 1.6)},
				{"name":"wing_l", "pos":Vector3(-0.6, 0.65, 0.3), "size":Vector3(0.3, 1.1, 0.12)},
				{"name":"wing_r", "pos":Vector3(-0.6, 0.65, -0.3), "size":Vector3(0.3, 1.1, 0.12)},
			]
		},
		{
			"key": "门框", "label_zh": "门框", "label_en": "DoorFrame",
			"target": Vector3(1.0, 2.4, 0.2), "row": 0, "col": 3,
			"blocks": [
				{"name":"left_pillar", "pos":Vector3(-0.45, 1.2, 0), "size":Vector3(0.1, 2.4, 0.15)},
				{"name":"right_pillar", "pos":Vector3(0.45, 1.2, 0), "size":Vector3(0.1, 2.4, 0.15)},
				{"name":"top_beam", "pos":Vector3(0, 2.35, 0), "size":Vector3(1.0, 0.1, 0.15)},
				{"name":"bottom", "pos":Vector3(0, 0.05, 0), "size":Vector3(1.0, 0.1, 0.15)},
			]
		},
		# Row 1
		{
			"key": "柱子", "label_zh": "石柱", "label_en": "Pillar",
			"target": Vector3(0.5, 3.0, 0.5), "row": 1, "col": 0,
			"blocks": [
				{"name":"shaft", "pos":Vector3(0, 1.5, 0), "size":Vector3(0.5, 2.6, 0.5)},
				{"name":"cap", "pos":Vector3(0, 2.9, 0), "size":Vector3(0.7, 0.2, 0.7)},
				{"name":"base", "pos":Vector3(0, 0.1, 0), "size":Vector3(0.65, 0.2, 0.65)},
			]
		},
		{
			"key": "楼梯", "label_zh": "楼梯", "label_en": "Stairs",
			"target": Vector3(2.0, 1.5, 2.0), "row": 1, "col": 1,
			"blocks": [
				{"name":"s1", "pos":Vector3(0, 0.1, 0), "size":Vector3(2.0, 0.3, 0.4)},
				{"name":"s2", "pos":Vector3(0, 0.4, 0.4), "size":Vector3(2.0, 0.3, 0.4)},
				{"name":"s3", "pos":Vector3(0, 0.7, 0.8), "size":Vector3(2.0, 0.3, 0.4)},
				{"name":"s4", "pos":Vector3(0, 1.0, 1.2), "size":Vector3(2.0, 0.3, 0.4)},
				{"name":"s5", "pos":Vector3(0, 1.3, 1.6), "size":Vector3(2.0, 0.3, 0.4)},
			]
		},
		{
			"key": "圆桶", "label_zh": "圆桶", "label_en": "Barrel",
			"target": Vector3(0.8, 1.2, 0.8), "row": 1, "col": 2,
			"blocks": [
				{"name":"bottom", "pos":Vector3(0, 0.3, 0), "size":Vector3(0.7, 0.4, 0.7)},
				{"name":"middle", "pos":Vector3(0, 0.7, 0), "size":Vector3(0.8, 0.3, 0.8)},
				{"name":"top", "pos":Vector3(0, 1.0, 0), "size":Vector3(0.7, 0.3, 0.7)},
			]
		},
		{
			"key": "桌", "label_zh": "桌子", "label_en": "Table",
			"target": Vector3(1.5, 0.8, 0.8), "row": 1, "col": 3,
			"blocks": [
				{"name":"tabletop", "pos":Vector3(0, 0.75, 0), "size":Vector3(1.5, 0.05, 0.8)},
				{"name":"leg_fl", "pos":Vector3(0.65, 0.35, 0.3), "size":Vector3(0.08, 0.7, 0.08)},
				{"name":"leg_fr", "pos":Vector3(-0.65, 0.35, 0.3), "size":Vector3(0.08, 0.7, 0.08)},
				{"name":"leg_bl", "pos":Vector3(0.65, 0.35, -0.3), "size":Vector3(0.08, 0.7, 0.08)},
				{"name":"leg_br", "pos":Vector3(-0.65, 0.35, -0.3), "size":Vector3(0.08, 0.7, 0.08)},
			]
		},
	]


func _initialize() -> void:
	print("=== BUILD GYM: Generating merged PH meshes and demo scene ===\n")

	# Ensure gym_meshes directory exists
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("gym_meshes"):
		dir.make_dir("gym_meshes")

	var objects = _define_objects()

	# Phase A: generate merged meshes
	var mesh_files: Array[String] = []
	mesh_files.resize(objects.size())
	var fit_pcts: Array[float] = []
	fit_pcts.resize(objects.size())

	for i in range(objects.size()):
		var obj = objects[i]
		var mesh_file = "res://gym_meshes/%s_ph.res" % obj.label_en.to_lower()
		mesh_files[i] = mesh_file

		var preset = PresetLib.get_preset(obj.key)
		var scaled = PresetLib._scale_preset(preset, obj.target, obj.key)
		scaled["description"] = obj.label_zh

		var merged = MeshBuilder.build_merged_mesh(scaled)
		if merged == null:
			push_error("Failed to build merged mesh for: " + obj.label_zh)
			mesh_files[i] = ""
			fit_pcts[i] = 0.0
			continue

		var err = ResourceSaver.save(merged, mesh_file)
		if err != OK:
			push_error("Failed to save mesh: %s (err=%d)" % [mesh_file, err])
		else:
			print("  Saved: " + mesh_file + " (surfaces=" + str(merged.get_surface_count()) + ")")

		# Compute fit %: ratio of mesh AABB size to target size, averaged across axes
		var mesh_aabb = merged.get_aabb()
		var fit_x = clampf(mesh_aabb.size.x / maxf(obj.target.x, 0.001), 0.0, 2.0)
		var fit_y = clampf(mesh_aabb.size.y / maxf(obj.target.y, 0.001), 0.0, 2.0)
		var fit_z = clampf(mesh_aabb.size.z / maxf(obj.target.z, 0.001), 0.0, 2.0)
		fit_pcts[i] = clampf((fit_x + fit_y + fit_z) / 3.0 * 100.0, 0.0, 100.0)

	# Phase B: write scene
	_write_scene(objects, mesh_files, fit_pcts)

	print("\n=== DONE: demo_gym.tscn written ===")
	quit(0)


func _write_scene(objects: Array, mesh_files: Array[String], fit_pcts: Array[float]) -> void:
	var sb := ""
	# Use a fresh uid
	var uid_str := "uid://demo_gym_v3"

	# ── Count load_steps ──
	var total_blocks := 0
	for obj in objects:
		total_blocks += obj.blocks.size()

	# materials: 3  +  plane: 1  +  box_meshes: total_blocks  +  ext_resources: mesh_files.count (non-empty)
	var ext_count := 0
	for f in mesh_files:
		if not f.is_empty():
			ext_count += 1

	var load_steps: int = 3 + 1 + total_blocks + ext_count

	sb += '[gd_scene load_steps=%d format=3 uid="%s"]\n\n' % [load_steps, uid_str]

	# ── ExtResources for merged PH meshes (MUST come before sub_resources in Godot 4.6) ──
	var ext_id_map := {}  # obj_idx -> "ext_label"
	for i in range(objects.size()):
		if mesh_files[i].is_empty():
			continue
		var f = mesh_files[i]
		var basename = f.get_file().get_basename()
		ext_id_map[i] = basename
		sb += '[ext_resource type="ArrayMesh" path="%s" id="%s"]\n\n' % [f, basename]

	# ── Materials ──
	sb += '[sub_resource type="StandardMaterial3D" id="mat_whitebox"]\n'
	sb += 'albedo_color = Color(0.8, 0.3, 0.3, 0.5)\n'
	sb += 'transparency = 1\n\n'

	sb += '[sub_resource type="StandardMaterial3D" id="mat_ph_gray"]\n'
	sb += 'albedo_color = Color(0.7, 0.7, 0.72, 1)\n'
	sb += 'roughness = 0.8\n'
	sb += 'metallic = 0.05\n\n'

	sb += '[sub_resource type="StandardMaterial3D" id="mat_floor"]\n'
	sb += 'albedo_color = Color(0.25, 0.25, 0.28, 1)\n'
	sb += 'roughness = 0.95\n\n'

	# ── PlaneMesh for floor ──
	sb += '[sub_resource type="PlaneMesh" id="plane_floor"]\n'
	sb += 'size = Vector2(52, 14)\n\n'

	# ── BoxMesh sub_resources for every whitebox block ──
	var box_id_counter := 0
	var box_id_map := {}  # (obj_idx, block_idx) -> "box_N"
	for i in range(objects.size()):
		var obj = objects[i]
		for j in range(obj.blocks.size()):
			var blk = obj.blocks[j]
			var bid = "box_%d" % box_id_counter
			box_id_map[Vector2i(i, j)] = bid
			box_id_counter += 1
			sb += '[sub_resource type="BoxMesh" id="%s"]\n' % bid
			sb += 'size = Vector3(%.4f, %.4f, %.4f)\n\n' % [blk.size.x, blk.size.y, blk.size.z]

	# ── Root node ──
	sb += '[node name="GymMap" type="Node3D"]\n\n'

	# ── Floor ──
	# Floor covers X from -10 to 42, Z from -5 to 5. Center at (16, -10, 0)
	sb += '[node name="Floor" type="MeshInstance3D" parent="."]\n'
	sb += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 16, -12, 0)\n'
	sb += 'mesh = SubResource("plane_floor")\n'
	sb += 'surface_material_override/0 = SubResource("mat_floor")\n\n'

	# ── Title ──
	sb += '[node name="Title" type="Label3D" parent="."]\n'
	sb += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 14, 5, 0)\n'
	sb += 'text = "GYM MAP — Metrics 白盒 vs AI PH 合并模式对比"\n'
	sb += 'font_size = 64\n'
	sb += 'billboard = 1\n'
	sb += 'pixel_size = 0.005\n\n'

	# ── Light ──
	sb += '[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]\n'
	sb += 'transform = Transform3D(0.866, -0.354, -0.354, 0.354, 0.933, -0.067, 0.354, -0.067, 0.933, 0, 10, 8)\n'
	sb += 'light_energy = 0.8\n\n'

	# ── Camera ──
	# Camera looks down at the scene center from above-front
	sb += '[node name="Camera3D" type="Camera3D" parent="."]\n'
	sb += 'transform = Transform3D(1, 0, 0, 0, 0.866, -0.5, 0, 0.5, 0.866, 14, 6, 28)\n\n'

	# ── 8 object pairs ──
	for i in range(objects.size()):
		var obj = objects[i]
		var row_y: float = -2.0 if obj.row == 0 else -8.0
		var col_x: float = float(obj.col) * 10.0  # 0, 10, 20, 30
		var left_x: float = col_x - 8.0
		var right_x: float = col_x + 3.0
		var n_blocks: int = obj.blocks.size()
		var fit_pct: float = fit_pcts[i]

		# ── LEFT: Whitebox group (Node3D with MeshInstance3D children) ──
		var wb_name = "%s_Whitebox" % obj.label_en
		sb += '[node name="%s" type="Node3D" parent="."]\n' % wb_name
		sb += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %.4f, %.4f, 0)\n' % [left_x, row_y]

		for j in range(n_blocks):
			var blk = obj.blocks[j]
			var bid = box_id_map[Vector2i(i, j)]
			var blk_name = "MI_%s" % blk.name
			sb += '[node name="%s" type="MeshInstance3D" parent="%s"]\n' % [blk_name, wb_name]
			sb += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %.4f, %.4f, %.4f)\n' % [blk.pos.x, blk.pos.y, blk.pos.z]
			sb += 'mesh = SubResource("%s")\n' % bid
			sb += 'surface_material_override/0 = SubResource("mat_whitebox")\n\n'

		# Annotation label for whitebox group
		var wb_top: float = _compute_group_top(obj.blocks)
		sb += '[node name="Label" type="Label3D" parent="%s"]\n' % wb_name
		sb += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, %.3f, 0)\n' % (wb_top + 0.5)
		sb += 'text = "%s | ⏹ %d | Fit %.1f%%"\n' % [obj.label_zh, n_blocks, fit_pct]
		sb += 'font_size = 28\n'
		sb += 'billboard = 1\n'
		sb += 'pixel_size = 0.01\n'
		sb += 'modulate = Color(1, 0.6, 0.6, 1)\n\n'

		# ── RIGHT: Merged PH group ──
		var ph_name = "PH_%s" % obj.label_en
		sb += '[node name="%s" type="Node3D" parent="."]\n' % ph_name
		sb += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, %.4f, %.4f, 0)\n' % [right_x, row_y]

		if ext_id_map.has(i):
			sb += '[node name="MergedMesh" type="MeshInstance3D" parent="%s"]\n' % ph_name
			sb += 'mesh = ExtResource("%s")\n' % ext_id_map[i]
			sb += 'surface_material_override/0 = SubResource("mat_ph_gray")\n\n'

		# Annotation label for PH
		sb += '[node name="Label" type="Label3D" parent="%s"]\n' % ph_name
		sb += 'transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, %.3f, 0)\n' % (wb_top + 0.5)
		sb += 'text = "PH %s | ⏹ %d | Fit %.1f%%"\n' % [obj.label_zh, n_blocks, fit_pct]
		sb += 'font_size = 28\n'
		sb += 'billboard = 1\n'
		sb += 'pixel_size = 0.01\n'
		sb += 'modulate = Color(0.5, 1, 0.5, 1)\n\n'

	# Write the scene file
	var f = FileAccess.open("res://demo_gym.tscn", FileAccess.WRITE)
	f.store_string(sb)
	f.close()
	print("  demo_gym.tscn written successfully (%d bytes)" % sb.length())


# Compute the top Y of a group from its blocks (pos.y + size.y/2)
static func _compute_group_top(blocks: Array) -> float:
	var max_y := 0.0
	for blk in blocks:
		var top: float = blk.pos.y + blk.size.y * 0.5
		if top > max_y:
			max_y = top
	return max_y


static func clampf(val: float, lo: float, hi: float) -> float:
	return maxf(lo, minf(hi, val))
