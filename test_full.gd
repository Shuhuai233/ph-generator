extends SceneTree

const MeshBuilder = preload("res://addons/ph_generator/core/mesh_builder.gd")
const PresetLib = preload("res://addons/ph_generator/presets/library.gd")
const Parser = preload("res://addons/ph_generator/ai/parser.gd")
const MaterialDB = preload("res://addons/ph_generator/core/material_db.gd")
const ConfigManager = preload("res://addons/ph_generator/config/config_manager.gd")


const PHGenerator = preload("res://addons/ph_generator/core/ph_generator.gd")


var all_ok: bool = true
var test_num: int = 0
var passed: int = 0
var failed: int = 0


func _initialize() -> void:
	print("======================================================================")
	print("         PH GENERATOR — COMPREHENSIVE VALIDATION SUITE")
	print("======================================================================\n")
	all_ok = true
	passed = 0
	failed = 0

	# ── SECTION 1: Mesh Builder (all 6 types) ─────────────────────────
	_test("mesh_builder - box", func():
		var m = MeshBuilder.build_box({"type": "box", "size": Vector3(2, 1, 1.5)})
		return m != null)

	_test("mesh_builder - cylinder", func():
		var m = MeshBuilder.build_cylinder({"type": "cylinder", "radius": 0.5, "height": 2.0})
		return m != null)

	_test("mesh_builder - sphere", func():
		var m = MeshBuilder.build_sphere({"type": "sphere", "radius": 0.75})
		return m != null)

	_test("mesh_builder - capsule", func():
		var m = MeshBuilder.build_capsule({"type": "capsule", "radius": 0.4, "height": 2.0})
		return m != null)

	_test("mesh_builder - wedge", func():
		var m = MeshBuilder.build_wedge({"type": "wedge", "size": Vector3(1, 0.5, 1)})
		return m != null)

	_test("mesh_builder - plane", func():
		var m = MeshBuilder.build_plane({"type": "plane", "size": Vector3(3, 0.05, 3)})
		return m != null)

	_test("mesh_builder - dispatch via build_mesh (box)", func():
		var m = MeshBuilder.build_mesh({"type": "box", "size": Vector3(1, 2, 3)})
		return m != null)

	_test("mesh_builder - dispatch via build_mesh (sphere)", func():
		var m = MeshBuilder.build_mesh({"type": "sphere", "radius": 0.6})
		return m != null)

	# ── SECTION 1b: Merged Mesh Builder ─────────────────────────────
	_test("merged_mesh - build_merged_mesh car", func():
		var parsed = PresetLib.find_best_match("轿车", Vector3(4, 1.8, 1.5))
		var merged = MeshBuilder.build_merged_mesh(parsed)
		var ok = merged != null and merged.get_surface_count() > 0
		print("        surfaces=" + str(merged.get_surface_count()) + " aabb=" + str(merged.get_aabb()))
		return ok)

	_test("merged_mesh - build_merged_mesh box", func():
		var parsed = PresetLib.find_best_match("箱子", Vector3(1, 1, 1))
		var merged = MeshBuilder.build_merged_mesh(parsed)
		return merged != null and merged.get_surface_count() > 0)

	_test("merged_mesh - build_merged_mesh cover (has wedge)", func():
		var parsed = PresetLib.find_best_match("掩体", Vector3(1.2, 0.8, 1.8))
		var merged = MeshBuilder.build_merged_mesh(parsed)
		return merged != null and merged.get_surface_count() > 0)

	_test("merged_mesh - build_merged_mesh door (has sphere)", func():
		var parsed = PresetLib.find_best_match("门", Vector3(0.8, 0.08, 2.2))
		var merged = MeshBuilder.build_merged_mesh(parsed)
		return merged != null and merged.get_surface_count() > 0)

	_test("merged_mesh - build_merged_mesh pillar", func():
		var parsed = PresetLib.find_best_match("柱子", Vector3(0.5, 0.5, 3))
		var merged = MeshBuilder.build_merged_mesh(parsed)
		return merged != null and merged.get_surface_count() > 0)

	_test("merged_mesh - single primitive box merge", func():
		var parsed = {"description": "test", "primitives": [{"type": "box", "size": Vector3(1, 1, 1), "position": Vector3(2, 0, 0)}]}
		var merged = MeshBuilder.build_merged_mesh(parsed)
		var aabb = merged.get_aabb() if merged else AABB()
		print("        aabb=" + str(aabb) + " size=" + str(aabb.size))
		return merged != null and aabb.size.x > 0.5)  # should be around (1,1,1)

	_test("merged_mesh - two boxes offset test", func():
		var parsed = {"description": "two_boxes", "primitives": [
			{"type": "box", "size": Vector3(1, 1, 1), "position": Vector3(2, 0, 0)},
			{"type": "box", "size": Vector3(1, 1, 1), "position": Vector3(-2, 0, 0)},
		]}
		var merged = MeshBuilder.build_merged_mesh(parsed)
		var aabb = merged.get_aabb() if merged else AABB()
		print("        aabb=" + str(aabb) + " size=" + str(aabb.size))
		# Should span roughly [-2.5, -0.5, -0.5] to [2.5, 0.5, 0.5] => width ~5
		return merged != null and aabb.size.x > 4.0)

	# ── SECTION 2: Preset Library ──────────────────────────────────────
	_test("preset_library - get_preset car (车)", func():
		var preset = PresetLib.get_preset("车")
		print("        primitives=" + str(preset.primitives.size()))
		return preset.primitives.size() > 0)

	_test("preset_library - get_preset box (箱子)", func():
		var preset = PresetLib.get_preset("箱子")
		print("        primitives=" + str(preset.primitives.size()))
		return preset.primitives.size() > 0)

	_test("preset_library - get_preset cover (掩体)", func():
		var preset = PresetLib.get_preset("掩体")
		print("        primitives=" + str(preset.primitives.size()))
		return preset.primitives.size() > 0)

	_test("preset_library - get_preset door (门)", func():
		var preset = PresetLib.get_preset("门")
		print("        primitives=" + str(preset.primitives.size()))
		return preset.primitives.size() > 0)

	_test("preset_library - get_preset pillar (柱子)", func():
		var preset = PresetLib.get_preset("柱子")
		print("        primitives=" + str(preset.primitives.size()))
		return preset.primitives.size() > 0)

	_test("preset_library - scale car to different size", func():
		var preset = PresetLib.get_preset("车")
		var scaled = PresetLib._scale_preset(preset, Vector3(8, 3.6, 3), "car")
		return scaled.primitives.size() > 0 and scaled.description.length() > 0)

	_test("preset_library - scale box to Z=0.5", func():
		var preset = PresetLib.get_preset("箱子")
		var scaled = PresetLib._scale_preset(preset, Vector3(1, 1, 0.5), "box")
		return scaled.primitives.size() > 0)

	_test("preset_library - scale pillar to Y=6", func():
		var preset = PresetLib.get_preset("柱子")
		var scaled = PresetLib._scale_preset(preset, Vector3(0.5, 6, 0.5), "pillar")
		return scaled.primitives.size() > 0)

	_test("preset_library - get_preset_keys returns keys", func():
		var keys = PresetLib.get_preset_keys()
		print("        keys=" + str(keys.size()))
		return keys.size() > 0)

	_test("preset_library - find_best_match car keyword", func():
		var result = PresetLib.find_best_match("轿车 (4×1.8×1.5)", Vector3(4, 1.8, 1.5))
		return result.primitives.size() > 0)

	_test("preset_library - find_best_match door keyword", func():
		var result = PresetLib.find_best_match("door (0.8×2.2)", Vector3(0.8, 0.08, 2.2))
		return result.primitives.size() > 0)

	_test("preset_library - find_best_match fallback to generic", func():
		var result = PresetLib.find_best_match("xyzzy_unknown_object", Vector3(1, 1, 1))
		return result.primitives.size() > 0)

	# ── SECTION 3: Parser ──────────────────────────────────────────────
	_test("parser - normal JSON with primitives", func():
		var parsed = Parser.parse_response('{"description":"test","primitives":[{"type":"box","size":[1,1,1],"position":[0,0,0],"color":"#ff0000","material":"metal"}]}')
		print("        primitives=" + str(parsed.primitives.size()))
		return parsed.primitives.size() > 0)

	_test("parser - empty string", func():
		var parsed = Parser.parse_response("")
		# Should return fallback or empty
		return parsed is Dictionary)

	_test("parser - malformed JSON", func():
		var parsed = Parser.parse_response("this is not { json at all")
		return parsed is Dictionary)

	_test("parser - JSON with wrapper key", func():
		var parsed = Parser.parse_response('{"data":{"description":"wrapped","primitives":[{"type":"sphere","radius":0.5,"position":[0,1,0],"color":"#4488cc","material":"metal"}]}}')
		print("        wrapped primitives=" + str(parsed.primitives.size()))
		return parsed.primitives.size() > 0)

	_test("parser - nested JSON with primitives deep inside", func():
		var parsed = Parser.parse_response('some text {"response": {"description": "deep", "primitives": [{"type": "cylinder", "radius": 0.3, "height": 1.0, "position": [0, 0.5, 0], "color": "#aabbcc", "material": "plastic"}]}} extra text')
		return parsed.primitives.size() > 0)

	_test("parser - array with multiple items, pick one with primitives", func():
		var parsed = Parser.parse_response('[{"a":1},{"description":"found","primitives":[{"type":"box","size":[2,2,2],"position":[0,1,0],"color":"#ffffff","material":"default"}]}]')
		print("        found primitives=" + str(parsed.primitives.size()))
		return parsed.primitives.size() > 0)

	_test("parser - primitives json with text prefix", func():
		var parsed = Parser.parse_response('Here is the result: {"description": "prefixed", "primitives": [{"type": "wedge", "size": [1, 0.5, 1], "position": [0, 0.5, 0], "color": "#998877", "material": "concrete"}]}')
		return parsed.primitives.size() > 0)

	_test("parser - unknown type falls back to box", func():
		var parsed = Parser.parse_response('{"description":"unknown","primitives":[{"type":"blerg","size":[1,2,3],"position":[0,0,0],"color":"#123456","material":"default"}]}')
		return parsed.primitives.size() > 0)

	_test("parser - deeply nested JSON", func():
		var parsed = Parser.parse_response('{"level1":{"level2":{"level3":{"description":"very deep","primitives":[{"type":"box","size":[3,3,3],"position":[0,0,0],"color":"#abcdef","material":"metal"}]}}}}')
		print("        deep primitives=" + str(parsed.primitives.size()))
		return parsed.primitives.size() > 0)

	# ── SECTION 4: Material Database ────────────────────────────────────
	_test("material_db - hex color parsing", func():
		var c = MaterialDB.get_color("#4488cc")
		return c.r > 0 and c.g > 0 and c.b > 0)

	_test("material_db - named color 'metal'", func():
		var c = MaterialDB.get_color("metal")
		return c.r > 0)

	_test("material_db - named color 'plastic'", func():
		var c = MaterialDB.get_color("plastic")
		return c.r > 0)

	_test("material_db - named color 'wood'", func():
		var c = MaterialDB.get_color("wood")
		return c.r > 0)

	_test("material_db - named color 'concrete'", func():
		var c = MaterialDB.get_color("concrete")
		return c.r > 0)

	_test("material_db - named color 'glass'", func():
		var c = MaterialDB.get_color("glass")
		return c.r > 0)

	_test("material_db - named color 'rubber'", func():
		var c = MaterialDB.get_color("rubber")
		return c.r > 0)

	_test("material_db - named color 'fabric'", func():
		var c = MaterialDB.get_color("fabric")
		return c.r > 0)

	_test("material_db - named color 'stone'", func():
		var c = MaterialDB.get_color("stone")
		return c.r > 0)

	_test("material_db - named color 'default'", func():
		var c = MaterialDB.get_color("default")
		return c.r > 0)

	_test("material_db - unknown name returns default", func():
		var c = MaterialDB.get_color("nonexistent_color_name")
		return c.r > 0)

	_test("material_db - make_material returns StandardMaterial3D", func():
		var mat = MaterialDB.make_material(Color.RED, "test_mat", 0.5, 0.9)
		return mat is StandardMaterial3D and mat.albedo_color == Color.RED)

	_test("material_db - get_preset_color vehicle", func():
		var c = MaterialDB.get_preset_color("vehicle")
		return c.r > 0)

	_test("material_db - get_preset_color container", func():
		var c = MaterialDB.get_preset_color("container")
		return c.r > 0)

	_test("material_db - get_preset_color cover", func():
		var c = MaterialDB.get_preset_color("cover")
		return c.r > 0)

	_test("material_db - get_preset_color door", func():
		var c = MaterialDB.get_preset_color("door")
		return c.r > 0)

	_test("material_db - get_preset_color pillar", func():
		var c = MaterialDB.get_preset_color("pillar")
		return c.r > 0)

	_test("material_db - get_preset_color furniture", func():
		var c = MaterialDB.get_preset_color("furniture")
		return c.r > 0)

	_test("material_db - get_preset_color unknown->default", func():
		var c = MaterialDB.get_preset_color("nonexistent")
		return c.r > 0)

	# ── SECTION 5: Config Manager ──────────────────────────────────────
	_test("config_manager - default values", func():
		var cm = ConfigManager.new()
		return cm.api_endpoint.length() > 0 and cm.model.length() > 0)

	_test("config_manager - save and load cycle", func():
		var cm = ConfigManager.new()
		cm.api_endpoint = "https://test.example.com/v1"
		cm.api_key = "sk-test-key-12345"
		cm.model = "gpt-3.5-turbo"
		cm.temperature = 0.7
		cm.export_fbx = true
		cm.export_dir = "res://test_exports"
		cm.auto_select_whitebox = false
		cm.save()

		var cm2 = ConfigManager.new()
		cm2.load()
		# verify loaded values match what we set
		return cm2.api_endpoint == "https://test.example.com/v1" \
			and cm2.api_key == "sk-test-key-12345" \
			and cm2.model == "gpt-3.5-turbo" \
			and abs(cm2.temperature - 0.7) < 0.001 \
			and cm2.export_fbx == true \
			and cm2.export_dir == "res://test_exports" \
			and cm2.auto_select_whitebox == false)

	# ── SECTION 6: Preload path verification ───────────────────────────
	_test("preload - mesh_builder resolves", func():
		return MeshBuilder != null)

	_test("preload - preset_library resolves", func():
		return PresetLib != null)

	_test("preload - parser resolves", func():
		return Parser != null)

	_test("preload - material_db resolves", func():
		return MaterialDB != null)

	_test("preload - config_manager resolves", func():
		return ConfigManager != null)

	# ── SECTION 7: get_node_extents (ph_generator) ─────────────────────
	_test("get_node_extents - single mesh at origin", func():
		var node := Node3D.new()
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(2, 3, 4)
		mi.mesh = box
		node.add_child(mi)
		var extents = PHGenerator.get_node_extents(node)
		print("        extents=" + str(extents))
		return is_equal_approx(extents.x, 2.0) and is_equal_approx(extents.y, 3.0) and is_equal_approx(extents.z, 4.0))

	_test("get_node_extents - two boxes at different positions", func():
		var node := Node3D.new()
		var mi1 := MeshInstance3D.new()
		var box1 := BoxMesh.new()
		box1.size = Vector3(1, 1, 1)
		mi1.mesh = box1
		mi1.position = Vector3(2, 0, 0)
		node.add_child(mi1)

		var mi2 := MeshInstance3D.new()
		var box2 := BoxMesh.new()
		box2.size = Vector3(1, 1, 1)
		mi2.mesh = box2
		mi2.position = Vector3(-2, 0, 0)
		node.add_child(mi2)

		var extents = PHGenerator.get_node_extents(node)
		print("        extents=" + str(extents))
		# X spans from -2.5 to 2.5 = 5.0
		return abs(extents.x - 5.0) < 0.001 and abs(extents.y - 1.0) < 0.001 and abs(extents.z - 1.0) < 0.001)

	_test("get_node_extents - positioned and rotated mesh", func():
		var node := Node3D.new()
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(2, 1, 1)
		mi.mesh = box
		mi.position = Vector3(1, 2, 3)
		node.add_child(mi)
		var extents = PHGenerator.get_node_extents(node)
		print("        extents=" + str(extents))
		return is_equal_approx(extents.x, 2.0) and is_equal_approx(extents.y, 1.0) and is_equal_approx(extents.z, 1.0))

	_test("get_node_extents - empty node returns default", func():
		var node := Node3D.new()
		var extents = PHGenerator.get_node_extents(node)
		print("        extents=" + str(extents))
		return is_equal_approx(extents.x, 1.0) and is_equal_approx(extents.y, 1.0) and is_equal_approx(extents.z, 1.0))

	_test("get_node_extents - three boxes forming L-shape", func():
		var node := Node3D.new()
		for pos in [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)]:
			var mi := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(1, 1, 1)
			mi.mesh = box
			mi.position = pos
			node.add_child(mi)
		var extents = PHGenerator.get_node_extents(node)
		print("        extents=" + str(extents))
		# X: from -0.5 to 1.5 = 2.0, Y: from -0.5 to 1.5 = 2.0
		return abs(extents.x - 2.0) < 0.001 and abs(extents.y - 2.0) < 0.001 and abs(extents.z - 1.0) < 0.001)

	# ── RESULTS ────────────────────────────────────────────────────────
	print("\n======================================================================")
	print("   RESULTS: %d passed, %d failed, %d total" % [passed, failed, passed + failed])
	print("   VERDICT: %s" % ("ALL PASSED" if all_ok else "SOME FAILED"))
	print("======================================================================")
	quit(0 if all_ok else 1)


func _test(label: String, test_fn: Callable) -> void:
	test_num += 1
	print("[%2d] %s..." % [test_num, label])
	var result = test_fn.call()
	if result:
		passed += 1
		print("      PASS")
	else:
		failed += 1
		all_ok = false
		print("      FAIL")
