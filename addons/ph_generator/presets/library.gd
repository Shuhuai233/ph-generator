@tool
extends RefCounted

const PRESETS = {
	"车": {
		"description": "轿车",
		"primitives": [
			{"type": "box", "size": [4.0, 0.7, 1.8], "position": [0, 0.75, 0], "color": "#4488cc", "material": "metal"},
			{"type": "box", "size": [2.0, 0.5, 1.7], "position": [-0.4, 1.35, 0], "color": "#88bbee", "material": "glass"},
			{"type": "cylinder", "radius": 0.3, "height": 0.25, "position": [-1.2, 0.15, 0.7], "color": "#222", "material": "rubber"},
			{"type": "cylinder", "radius": 0.3, "height": 0.25, "position": [-1.2, 0.15, -0.7], "color": "#222", "material": "rubber"},
			{"type": "cylinder", "radius": 0.3, "height": 0.25, "position": [1.2, 0.15, 0.7], "color": "#222", "material": "rubber"},
			{"type": "cylinder", "radius": 0.3, "height": 0.25, "position": [1.2, 0.15, -0.7], "color": "#222", "material": "rubber"}
		]
	},
	"箱子": {
		"description": "木箱",
		"primitives": [
			{"type": "box", "size": [1.0, 0.95, 1.0], "position": [0, 0.5, 0], "color": "#8c613d", "material": "wood"},
			{"type": "box", "size": [1.02, 0.05, 1.02], "position": [0, 1.0, 0], "color": "#a0704d", "material": "wood"},
			{"type": "box", "size": [0.06, 0.08, 0.06], "position": [0.47, 0.0, 0.47], "color": "#8899aa", "material": "metal"},
			{"type": "box", "size": [0.06, 0.08, 0.06], "position": [-0.47, 0.0, 0.47], "color": "#8899aa", "material": "metal"},
			{"type": "box", "size": [0.06, 0.08, 0.06], "position": [0.47, 0.0, -0.47], "color": "#8899aa", "material": "metal"},
			{"type": "box", "size": [0.06, 0.08, 0.06], "position": [-0.47, 0.0, -0.47], "color": "#8899aa", "material": "metal"}
		]
	},
	"掩体": {
		"description": "混凝土掩体",
		"primitives": [
			{"type": "box", "size": [1.2, 0.8, 1.8], "position": [0, 0.5, 0], "color": "#a6a399", "material": "concrete"},
			{"type": "wedge", "size": [1.0, 0.3, 1.6], "position": [0, 1.05, 0], "color": "#969389", "material": "concrete"},
			{"type": "box", "size": [0.3, 1.1, 0.12], "position": [-0.6, 0.65, 0.3], "color": "#b6b3a9", "material": "concrete"},
			{"type": "box", "size": [0.3, 1.1, 0.12], "position": [-0.6, 0.65, -0.3], "color": "#b6b3a9", "material": "concrete"}
		]
	},
	"门": {
		"description": "木门",
		"primitives": [
			{"type": "box", "size": [0.8, 0.07, 2.2], "position": [0, 1.1, 0], "color": "#8c613d", "material": "wood"},
			{"type": "box", "size": [0.84, 0.1, 2.24], "position": [0, 1.1, 0], "color": "#7a5535", "material": "wood"},
			{"type": "sphere", "radius": 0.04, "position": [0.25, 1.08, 0], "color": "#cccc99", "material": "metal"}
		]
	},
	"柱子": {
		"description": "石柱",
		"primitives": [
			{"type": "box", "size": [0.5, 2.6, 0.5], "position": [0, 1.5, 0], "color": "#c8bfb0", "material": "stone"},
			{"type": "box", "size": [0.7, 0.2, 0.7], "position": [0, 2.9, 0], "color": "#d8cfc0", "material": "stone"},
			{"type": "box", "size": [0.65, 0.2, 0.65], "position": [0, 0.1, 0], "color": "#d8cfc0", "material": "stone"}
		]
	},
	"楼梯": {
		"description": "楼梯",
		"primitives": [
			{"type": "box", "size": [3, 0.15, 0.3], "position": [0, 0.1, 0], "color": "#a6a399", "material": "concrete"},
			{"type": "box", "size": [3, 0.15, 0.3], "position": [0, 0.3, 0.3], "color": "#a6a399", "material": "concrete"},
			{"type": "box", "size": [3, 0.15, 0.3], "position": [0, 0.5, 0.6], "color": "#a6a399", "material": "concrete"},
			{"type": "box", "size": [3, 0.15, 0.3], "position": [0, 0.7, 0.9], "color": "#a6a399", "material": "concrete"},
			{"type": "box", "size": [3, 0.15, 0.3], "position": [0, 0.9, 1.2], "color": "#a6a399", "material": "concrete"}
		]
	},
	"窗": {
		"description": "窗户",
		"primitives": [
			{"type": "box", "size": [1.2, 0.08, 1.5], "position": [0, 0.75, 0], "color": "#b2b8bf", "material": "plastic"},
			{"type": "box", "size": [1.0, 0.02, 1.3], "position": [0, 0.75, 0], "color": "#80b8d9", "material": "glass"},
			{"type": "box", "size": [0.04, 1.3, 0.02], "position": [0, 0.75, 0], "color": "#b2b8bf", "material": "plastic"}
		]
	},
	"沙发": {
		"description": "沙发",
		"primitives": [
			{"type": "box", "size": [2.0, 0.4, 0.8], "position": [0, 0.2, -0.1], "color": "#5577aa", "material": "fabric"},
			{"type": "box", "size": [2.0, 0.5, 0.15], "position": [0, 0.65, 0.65], "color": "#5577aa", "material": "fabric"},
			{"type": "box", "size": [0.2, 0.5, 0.8], "position": [-1.0, 0.45, -0.1], "color": "#4466aa", "material": "fabric"},
			{"type": "box", "size": [0.2, 0.5, 0.8], "position": [1.0, 0.45, -0.1], "color": "#4466aa", "material": "fabric"}
		]
	},
	"桌": {
		"description": "桌子",
		"primitives": [
			{"type": "box", "size": [1.5, 0.05, 0.8], "position": [0, 0.75, 0], "color": "#8c613d", "material": "wood"},
			{"type": "box", "size": [0.08, 0.7, 0.08], "position": [0.65, 0.35, 0.3], "color": "#7a5535", "material": "wood"},
			{"type": "box", "size": [0.08, 0.7, 0.08], "position": [-0.65, 0.35, 0.3], "color": "#7a5535", "material": "wood"},
			{"type": "box", "size": [0.08, 0.7, 0.08], "position": [0.65, 0.35, -0.3], "color": "#7a5535", "material": "wood"},
			{"type": "box", "size": [0.08, 0.7, 0.08], "position": [-0.65, 0.35, -0.3], "color": "#7a5535", "material": "wood"}
		]
	},
	"椅": {
		"description": "椅子",
		"primitives": [
			{"type": "box", "size": [0.45, 0.04, 0.45], "position": [0, 0.45, 0], "color": "#8c613d", "material": "wood"},
			{"type": "box", "size": [0.45, 0.3, 0.04], "position": [0, 0.7, 0.2], "color": "#8c613d", "material": "wood"},
			{"type": "box", "size": [0.04, 0.42, 0.04], "position": [0.18, 0.22, 0.18], "color": "#7a5535", "material": "wood"},
			{"type": "box", "size": [0.04, 0.42, 0.04], "position": [-0.18, 0.22, 0.18], "color": "#7a5535", "material": "wood"},
			{"type": "box", "size": [0.04, 0.42, 0.04], "position": [0.18, 0.22, -0.18], "color": "#7a5535", "material": "wood"},
			{"type": "box", "size": [0.04, 0.42, 0.04], "position": [-0.18, 0.22, -0.18], "color": "#7a5535", "material": "wood"}
		]
	}
}

const KEYWORDS = {
	"车": ["车", "轿车", "车辆", "汽车", "car", "vehicle", "truck", "卡车", "货车"],
	"箱子": ["箱", "箱子", "木箱", "货箱", "box", "crate", "container", "货柜"],
	"掩体": ["掩体", "掩蔽", "cover", "barrier", "障碍", "防", "墙"],
	"门": ["门", "door", "gate", "通道", "入口", "出口"],
	"柱子": ["柱", "柱子", "pillar", "column", "柱体", "立柱"],
	"楼梯": ["楼梯", "台阶", "stairs", "stair", "阶梯"],
	"窗": ["窗", "窗户", "window", "玻璃", "窗口"],
	"沙发": ["沙发", "sofa", "couch", "seat", "座椅", "椅子"],
	"桌": ["桌", "桌子", "table", "desk", "台"],
	"椅": ["椅", "凳子", "chair", "stool", "凳"],
}


static func find_best_match(description: String, dimensions: Vector3) -> Dictionary:
	var lower = description.to_lower()
	var best_key = ""
	var best_score = -1

	for preset_key in KEYWORDS:
		for kw in KEYWORDS[preset_key]:
			if kw in lower:
				var score = kw.length()
				if score > best_score:
					best_score = score
					best_key = preset_key

	if best_key.is_empty():
		# Default: just a box matching the dimensions
		best_key = "箱子"
		return _scale_preset(PRESETS["箱子"], dimensions, "Generic Box")

	return _scale_preset(PRESETS[best_key], dimensions, best_key)


static func _scale_preset(preset: Dictionary, target_dims: Vector3, _type_name: String) -> Dictionary:
	var result = {"description": preset["description"], "primitives": []}
	var orig = preset["primitives"]

	var preset_bbox = _approx_bbox([Vector3(1, 1, 1)])
	if orig.size() > 0 and orig[0].has("size"):
		preset_bbox = _approx_bbox(orig)

	var sx = target_dims.x / preset_bbox.x if abs(preset_bbox.x) > 0.001 else 1.0
	var sy = target_dims.y / preset_bbox.y if abs(preset_bbox.y) > 0.001 else 1.0
	var sz = target_dims.z / preset_bbox.z if abs(preset_bbox.z) > 0.001 else 1.0

	var uniform_scale = (sx + sy + sz) / 3.0

	for p in orig:
		var entry = p.duplicate(true)

		if entry.has("size"):
			var s = entry["size"]
			if s is Vector3:
				entry["size"] = Vector3(s.x * sx, s.y * sy, s.z * sz)
			elif s is Array:
				entry["size"] = [s[0] * sx, s[1] * sy, s[2] * sz]

		if entry.has("radius"):
			entry["radius"] = entry["radius"] * uniform_scale
		if entry.has("height"):
			entry["height"] = entry["height"] * uniform_scale

		if entry.has("position"):
			var pos = entry["position"]
			if pos is Vector3:
				entry["position"] = Vector3(pos.x * sx, pos.y * sy, pos.z * sz)
			elif pos is Array:
				entry["position"] = [pos[0] * sx, pos[1] * sy, pos[2] * sz]

		result["primitives"].append(entry)

	return result


static func _approx_bbox(primitives: Array) -> Vector3:
	var maxp = Vector3.ONE * 0.001
	for p in primitives:
		if not p is Dictionary:
			continue
		var s = _get_size(p)
		var pos = Vector3.ZERO
		if p.has("position"):
			pos = _to_v3(p["position"])
		var corner = pos.abs() + s * 0.5
		maxp = Vector3(max(maxp.x, corner.x * 2), max(maxp.y, corner.y * 2), max(maxp.z, corner.z * 2))
	return maxp


static func _get_size(p: Dictionary) -> Vector3:
	if p.has("size"):
		return _to_v3(p["size"])
	if p.has("radius") and p.has("height"):
		var r = p["radius"]
		var h = p["height"]
		return Vector3(r * 2, h, r * 2)
	if p.has("radius"):
		var r = p["radius"]
		return Vector3(r * 2, r * 2, r * 2)
	return Vector3(1, 1, 1)


static func _to_v3(v) -> Vector3:
	if v is Vector3:
		return v
	if v is Array and v.size() >= 3:
		return Vector3(float(v[0]), float(v[1]), float(v[2]))
	return Vector3(1, 1, 1)


static func get_preset_keys() -> PackedStringArray:
	return PackedStringArray(PRESETS.keys())


static func get_preset(key: String) -> Dictionary:
	return PRESETS.get(key, PRESETS["箱子"]).duplicate(true)
