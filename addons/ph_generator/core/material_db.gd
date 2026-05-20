@tool
class_name material_db
extends RefCounted

const DEFAULT_COLORS = {
	"metal": Color(0.55, 0.57, 0.60),
	"plastic": Color(0.70, 0.73, 0.75),
	"wood": Color(0.55, 0.38, 0.24),
	"concrete": Color(0.65, 0.64, 0.60),
	"glass": Color(0.50, 0.70, 0.85, 0.6),
	"rubber": Color(0.15, 0.15, 0.15),
	"fabric": Color(0.45, 0.50, 0.40),
	"stone": Color(0.55, 0.52, 0.48),
	"default": Color(0.60, 0.60, 0.65),
}

static func get_color(hex_or_name: String) -> Color:
	if hex_or_name.begins_with("#"):
		return Color(hex_or_name)
	if hex_or_name in DEFAULT_COLORS:
		return DEFAULT_COLORS[hex_or_name]
	return DEFAULT_COLORS["default"]


static func make_material(color: Color, name: String = "ph_material", roughness: float = 0.85, metallic: float = 0.1) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	mat.resource_name = name
	return mat


static func get_preset_color(category: String) -> Color:
	var presets = {
		"vehicle": Color(0.30, 0.50, 0.70),
		"container": Color(0.65, 0.35, 0.25),
		"cover": Color(0.45, 0.50, 0.45),
		"door": Color(0.55, 0.38, 0.24),
		"pillar": Color(0.75, 0.73, 0.68),
		"furniture": Color(0.55, 0.45, 0.60),
		"default": Color(0.60, 0.65, 0.70),
	}
	return presets.get(category, presets["default"])
