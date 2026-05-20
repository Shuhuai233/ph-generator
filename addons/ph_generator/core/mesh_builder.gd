@tool
class_name mesh_builder
extends RefCounted

static func build_mesh(primitive: Dictionary) -> ArrayMesh:
	var ptype: String = primitive.get("type", "box")
	match ptype:
		"box":
			return build_box(primitive)
		"cylinder":
			return build_cylinder(primitive)
		"sphere":
			return build_sphere(primitive)
		"capsule":
			return build_capsule(primitive)
		"wedge":
			return build_wedge(primitive)
		"plane":
			return build_plane(primitive)
		_:
			return build_box(primitive)


static func build_box(data: Dictionary) -> ArrayMesh:
	var s = _get_vec3_size(data)
	var sx = s.x / 2.0; var sy = s.y / 2.0; var sz = s.z / 2.0

	var vts = PackedVector3Array([
		Vector3(-sx, -sy, -sz), Vector3( sx, -sy, -sz), Vector3( sx,  sy, -sz), Vector3(-sx,  sy, -sz),
		Vector3(-sx, -sy,  sz), Vector3( sx, -sy,  sz), Vector3( sx,  sy,  sz), Vector3(-sx,  sy,  sz),
	])

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	add_quad(st, vts, 0, 1, 2, 3)
	add_quad(st, vts, 1, 5, 6, 2)
	add_quad(st, vts, 5, 4, 7, 6)
	add_quad(st, vts, 4, 0, 3, 7)
	add_quad(st, vts, 3, 2, 6, 7)
	add_quad(st, vts, 4, 5, 1, 0)
	st.generate_normals()
	return st.commit()


static func build_cylinder(data: Dictionary, segments: int = 16) -> ArrayMesh:
	var radius: float = data.get("radius", 0.5)
	var height: float = data.get("height", 1.0)
	var hh = height / 2.0

	var top_center = Vector3(0, hh, 0)
	var bot_center = Vector3(0, -hh, 0)

	var top_ring = PackedVector3Array()
	var bot_ring = PackedVector3Array()
	for i in range(segments):
		var angle = TAU * float(i) / float(segments)
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		top_ring.append(Vector3(x, hh, z))
		bot_ring.append(Vector3(x, -hh, z))

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(segments):
		var ni = (i + 1) % segments
		add_tri(st, top_center, top_ring[ni], top_ring[i])
		add_tri(st, bot_center, bot_ring[i], bot_ring[ni])

	for i in range(segments):
		var ni = (i + 1) % segments
		tri(st, bot_ring[i], top_ring[i], top_ring[ni])
		tri(st, bot_ring[i], top_ring[ni], bot_ring[ni])

	st.generate_normals()
	return st.commit()


static func build_sphere(data: Dictionary, segments: int = 12) -> ArrayMesh:
	var radius: float = data.get("radius", 0.5)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for lat in range(segments):
		var phi1 = PI * float(lat) / float(segments) - PI / 2.0
		var phi2 = PI * float(lat + 1) / float(segments) - PI / 2.0
		for lon in range(segments * 2):
			var theta1 = TAU * float(lon) / float(segments * 2)
			var theta2 = TAU * float(lon + 1) / float(segments * 2)
			var p1 = spherical(Vector3.ZERO, radius, phi1, theta1)
			var p2 = spherical(Vector3.ZERO, radius, phi2, theta1)
			var p3 = spherical(Vector3.ZERO, radius, phi2, theta2)
			var p4 = spherical(Vector3.ZERO, radius, phi1, theta2)
			add_vertex_list(st, [p1, p2, p3, p1, p3, p4])

	st.generate_normals()
	return st.commit()


static func build_capsule(data: Dictionary, segments: int = 16) -> ArrayMesh:
	var radius: float = data.get("radius", 0.5)
	var height: float = data.get("height", 2.0)
	var hh = height / 2.0
	var upper_pole = Vector3(0, hh + radius, 0)
	var lower_pole = Vector3(0, -(hh + radius), 0)

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var hsegments = int(max(segments / 2, 4))

	for lat in range(hsegments):
		var phi1 = PI / 2.0 * float(lat) / float(hsegments)
		var phi2 = PI / 2.0 * float(lat + 1) / float(hsegments)
		var y1 = upper_pole.y - radius * sin(phi1)
		var y2 = upper_pole.y - radius * sin(phi2)
		var r1 = radius * cos(phi1)
		var r2 = radius * cos(phi2)
		for lon in range(segments):
			var a1 = TAU * float(lon) / float(segments)
			var a2 = TAU * float(lon + 1) / float(segments)
			var p1 = Vector3(cos(a1) * r1, y1, sin(a1) * r1)
			var p2 = Vector3(cos(a1) * r2, y2, sin(a1) * r2)
			var p3 = Vector3(cos(a2) * r2, y2, sin(a2) * r2)
			var p4 = Vector3(cos(a2) * r1, y1, sin(a2) * r1)
			add_vertex_list(st, [p1, p2, p3, p1, p3, p4])

	var cylinder_top = upper_pole.y - radius
	var cylinder_bot = lower_pole.y + radius
	for i in range(segments):
		var a1 = TAU * float(i) / float(segments)
		var a2 = TAU * float(i + 1) / float(segments)
		var b1 = Vector3(cos(a1) * radius, cylinder_bot, sin(a1) * radius)
		var t1 = Vector3(cos(a1) * radius, cylinder_top, sin(a1) * radius)
		var t2 = Vector3(cos(a2) * radius, cylinder_top, sin(a2) * radius)
		var b2 = Vector3(cos(a2) * radius, cylinder_bot, sin(a2) * radius)
		add_vertex_list(st, [b1, t1, t2, b1, t2, b2])

	for lat in range(hsegments):
		var phi1 = PI / 2.0 * float(lat) / float(hsegments)
		var phi2 = PI / 2.0 * float(lat + 1) / float(hsegments)
		var y1 = lower_pole.y + radius * sin(phi1)
		var y2 = lower_pole.y + radius * sin(phi2)
		var r1 = radius * cos(phi1)
		var r2 = radius * cos(phi2)
		for lon in range(segments):
			var a1 = TAU * float(lon) / float(segments)
			var a2 = TAU * float(lon + 1) / float(segments)
			var p1 = Vector3(cos(a1) * r1, y1, sin(a1) * r1)
			var p2 = Vector3(cos(a1) * r2, y2, sin(a1) * r2)
			var p3 = Vector3(cos(a2) * r2, y2, sin(a2) * r2)
			var p4 = Vector3(cos(a2) * r1, y1, sin(a2) * r1)
			add_vertex_list(st, [p1, p2, p3, p1, p3, p4])

	st.generate_normals()
	return st.commit()


static func build_wedge(data: Dictionary) -> ArrayMesh:
	var s = _get_vec3_size(data)
	var sx = s.x / 2.0; var sy = s.y / 2.0; var sz = s.z / 2.0

	var v0 = Vector3(-sx, -sy, -sz)
	var v1 = Vector3( sx, -sy, -sz)
	var v2 = Vector3( sx, -sy,  sz)
	var v3 = Vector3(-sx, -sy,  sz)
	var v4 = Vector3(-sx,  sy, -sz)
	var v5 = Vector3( sx,  sy, -sz)

	var front = PackedVector3Array([v0, v1, v5, v4])
	var bottom = PackedVector3Array([v0, v3, v2, v1])
	var back = PackedVector3Array([v3, v4, v5, v2])

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	add_quad(st, front, 0, 1, 2, 3)
	add_tri(st, v0, v5, v4)
	add_tri(st, v0, v1, v5)
	add_quad(st, bottom, 0, 1, 2, 3)
	add_quad(st, back, 0, 1, 2, 3)
	st.generate_normals()
	return st.commit()


static func build_plane(data: Dictionary) -> ArrayMesh:
	var s = _get_vec3_size(data)
	var sx = s.x / 2.0; var sz = s.z / 2.0

	var pts = PackedVector3Array([
		Vector3(-sx, 0, -sz),
		Vector3( sx, 0, -sz),
		Vector3( sx, 0,  sz),
		Vector3(-sx, 0,  sz),
	])

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	add_quad(st, pts, 0, 1, 2, 3)
	add_quad(st, pts, 3, 2, 1, 0)
	st.generate_normals()
	return st.commit()


static func add_quad(st: SurfaceTool, vts: PackedVector3Array, a: int, b: int, c: int, d: int) -> void:
	tri(st, vts[a], vts[b], vts[c])
	tri(st, vts[a], vts[c], vts[d])


static func add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	tri(st, a, b, c)


static func tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)


static func add_vertex_list(st: SurfaceTool, verts: Array) -> void:
	for v in verts:
		st.add_vertex(v)


static func spherical(origin: Vector3, radius: float, phi: float, theta: float) -> Vector3:
	return origin + Vector3(
		radius * cos(phi) * cos(theta),
		radius * sin(phi),
		radius * cos(phi) * sin(theta)
	)


static func _get_vec3_size(data: Dictionary) -> Vector3:
	var raw = data.get("size", Vector3(1, 1, 1))
	if raw is Vector3:
		return raw
	if raw is Array and raw.size() >= 3:
		return Vector3(float(raw[0]), float(raw[1]), float(raw[2]))
	return Vector3(1, 1, 1)
