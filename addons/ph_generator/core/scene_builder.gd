@tool
extends RefCounted

const MeshBuilder = preload("res://addons/ph_generator/core/mesh_builder.gd")
const MaterialDB = preload("res://addons/ph_generator/core/material_db.gd")

var _config

func set_config(cm) -> void:
	_config = cm


func build_ph_root(parsed: Dictionary, scene_root: Node, ph_name: String = "PH_Generated") -> Node3D:
	var existing = scene_root.get_node_or_null(ph_name)
	if existing:
		if existing.get_parent():
			existing.get_parent().remove_child(existing)
		existing.queue_free()

	var root = Node3D.new()
	root.name = ph_name

	var desc = parsed.get("description", "PH")
	var label = Label3D.new()
	label.name = "Label"
	label.text = desc
	label.font_size = 32
	label.modulate = Color.WHITE
	label.position = Vector3(0, 2.5, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.01
	root.add_child(label)

	var primitives = parsed.get("primitives", [])
	for i in range(primitives.size()):
		var p = primitives[i]
		var mi = _create_mesh_instance(p, i)
		if mi:
			root.add_child(mi)

	var coll = _create_collision_body(parsed)
	if coll:
		root.add_child(coll)

	scene_root.add_child(root)

	root.propagate_call("set_owner", [scene_root])

	return root


func _create_mesh_instance(primitive: Dictionary, idx: int) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	mi.name = "Part_%d_%s" % [idx, primitive.get("type", "box")]

	var mesh = MeshBuilder.build_mesh(primitive)
	if mesh == null:
		return null
	mi.mesh = mesh

	var color = MaterialDB.get_color(primitive.get("color", "#888888"))
	var mat = MaterialDB.make_material(color, "ph_mat_%d" % idx)
	mi.set_surface_override_material(0, mat)

	if primitive.has("position"):
		var pos = primitive["position"]
		if pos is Vector3:
			mi.position = pos
		elif pos is Array:
			mi.position = Vector3(pos[0], pos[1], pos[2])

	return mi


func _create_collision_body(parsed: Dictionary) -> StaticBody3D:
	var sb = StaticBody3D.new()
	sb.name = "CollisionBody"

	var primitives = parsed.get("primitives", [])
	for i in range(primitives.size()):
		var p = primitives[i]
		var cs = CollisionShape3D.new()
		cs.name = "Collision_%d" % i

		var shape: Shape3D
		var ptype = p.get("type", "box")

		if ptype == "box" or ptype == "wedge" or ptype == "plane":
			var bs = BoxShape3D.new()
			if p.has("size"):
				var sz = p["size"]
				if sz is Vector3:
					bs.size = sz
				elif sz is Array:
					bs.size = Vector3(sz[0], sz[1], sz[2])
			shape = bs
		elif ptype == "cylinder":
			var cyl = CylinderShape3D.new()
			cyl.radius = p.get("radius", 0.5)
			cyl.height = p.get("height", 1.0)
			shape = cyl
		elif ptype == "sphere":
			var sph = SphereShape3D.new()
			sph.radius = p.get("radius", 0.5)
			shape = sph
		elif ptype == "capsule":
			var cap = CapsuleShape3D.new()
			cap.radius = p.get("radius", 0.5)
			cap.height = p.get("height", 1.0)
			shape = cap

		if shape:
			cs.shape = shape

		if p.has("position"):
			var pos = p["position"]
			if pos is Vector3:
				cs.position = pos
			elif pos is Array:
				cs.position = Vector3(pos[0], pos[1], pos[2])

		sb.add_child(cs)

	return sb


func build_ph_root_merged(parsed: Dictionary, scene_root: Node, ph_name: String = "PH_Generated") -> Node3D:
	var existing = scene_root.get_node_or_null(ph_name)
	if existing:
		if existing.get_parent():
			existing.get_parent().remove_child(existing)
		existing.queue_free()

	var root = Node3D.new()
	root.name = ph_name

	var desc = parsed.get("description", "PH")
	var label = Label3D.new()
	label.name = "Label"
	label.text = desc
	label.font_size = 32
	label.modulate = Color.WHITE
	label.position = Vector3(0, 2.5, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.pixel_size = 0.01
	root.add_child(label)

	# Single merged mesh instance
	var merged_mesh = MeshBuilder.build_merged_mesh(parsed)
	if merged_mesh != null:
		var mi = MeshInstance3D.new()
		mi.name = "MergedMesh"
		mi.mesh = merged_mesh

		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.70, 0.70, 0.72)
		mat.roughness = 0.8
		mat.metallic = 0.05
		mi.set_surface_override_material(0, mat)
		root.add_child(mi)

		# Collision from merged mesh AABB
		var sb = StaticBody3D.new()
		sb.name = "CollisionBody"
		var cs = CollisionShape3D.new()
		cs.name = "CollisionShape"

		# Try convex hull first, fall back to box from AABB
		var convex_shape := merged_mesh.create_convex_shape(true, true) as Shape3D
		if convex_shape:
			cs.shape = convex_shape
		else:
			var aabb = merged_mesh.get_aabb()
			var box_shape := BoxShape3D.new()
			box_shape.size = aabb.size
			cs.shape = box_shape
			# Offset the collision shape to center of AABB
			cs.position = aabb.get_center()

		sb.add_child(cs)
		root.add_child(sb)

	scene_root.add_child(root)

	root.propagate_call("set_owner", [scene_root])

	return root
