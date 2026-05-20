@tool
class_name Parser
extends RefCounted

static func parse_response(content: String) -> Dictionary:
	var json = JSON.parse_string(content)
	if json == null:
		push_error("Failed to parse JSON from LLM response")
		return _try_deep_search(content)

	if json is Dictionary:
		if json.has("primitives"):
			return _normalize_dict(json)
		for key in json:
			var val = json[key]
			if val is Dictionary and val.has("primitives"):
				return _normalize_dict(val)

	if json is Array:
		for item in json:
			if item is Dictionary and item.has("primitives"):
				return _normalize_dict(item)

	return _try_deep_search(content)


static func _try_deep_search(content: String) -> Dictionary:
	var start = content.find("\"primitives\"")
	if start == -1:
		start = content.find("\"description\"")
	if start == -1:
		return _build_fallback(content)

	var brace_count = 0
	var obj_start = -1
	for i in range(start, 0, -1):
		if content[i] == "{":
			obj_start = i
			break

	if obj_start == -1:
		return {}

	for i in range(obj_start, content.length()):
		if content[i] == "{":
			brace_count += 1
		elif content[i] == "}":
			brace_count -= 1
			if brace_count == 0:
				var sub = content.substr(obj_start, i - obj_start + 1)
				var json = JSON.parse_string(sub)
				if json is Dictionary and json.has("primitives"):
					return _normalize_dict(json)
				break

	return {}


static func _build_fallback(content: String) -> Dictionary:
	return {
		"description": content.substr(0, min(100, content.length())),
		"primitives": [{"type": "box", "size": [1, 1, 1], "position": [0, 0.5, 0], "color": "#AAAAAA", "material": "default"}]
	}


static func _normalize_dict(data: Dictionary) -> Dictionary:
	var result = {}
	result["description"] = data.get("description", "Unnamed PH")

	var raw_primitives = data.get("primitives", [])
	var primitives = []
	for p in raw_primitives:
		var entry = {}
		var ptype = p.get("type", "box")
		if ptype == "box" or ptype == "wedge" or ptype == "plane":
			entry["type"] = ptype
			entry["size"] = _as_vec3(p.get("size", [1, 1, 1]))
		elif ptype == "cylinder" or ptype == "capsule":
			entry["type"] = ptype
			entry["radius"] = p.get("radius", 0.5)
			entry["height"] = p.get("height", 1.0)
		elif ptype == "sphere":
			entry["type"] = ptype
			entry["radius"] = p.get("radius", 0.5)
		else:
			entry["type"] = "box"
			entry["size"] = _as_vec3(p.get("size", [1, 1, 1]))

		entry["position"] = _as_vec3(p.get("position", [0, 0, 0]))
		entry["color"] = p.get("color", "#888888")
		entry["material"] = p.get("material", "default")

		if not entry["color"].begins_with("#"):
			entry["color"] = "#888888"

		primitives.append(entry)

	result["primitives"] = primitives
	return result


static func _as_vec3(value) -> Vector3:
	if value is Vector3:
		return value
	if value is Array and value.size() >= 3:
		return Vector3(float(value[0]), float(value[1]), float(value[2]))
	return Vector3(1, 1, 1)
