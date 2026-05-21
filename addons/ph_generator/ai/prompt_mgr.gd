@tool
extends RefCounted

const SYSTEM_PROMPT = """你是一个3D占位模型（Placeholder）生成器。
你收到一个白盒描述（包含尺寸信息），需要将其拆解为基本几何体的组合，输出严格的JSON格式。

## 可用的基本几何体类型
- "box": 长方体，需要 size [width, height, depth]
- "cylinder": 圆柱体，需要 radius (半径) 和 height (高度)
- "sphere": 球体，需要 radius (半径)
- "capsule": 胶囊体，需要 radius (半径) 和 height (高度，不含半球)
- "wedge": 楔形体/三角棱柱，需要 size [width, height, depth]
- "plane": 平面，需要 size [width, 0.05, depth]

## 颜色常量（建议使用）
- "metal": #8899aa - 金属
- "plastic": #b2b8bf - 塑料
- "wood": #8c613d - 木材
- "concrete": #a6a399 - 混凝土
- "glass": #80b8d9 - 玻璃
- "rubber": #262626 - 橡胶
- "fabric": #738066 - 织物

## 材质分类
- "metal": 金属质感 (roughness=0.5, metallic=0.8)
- "plastic": 塑料质感 (roughness=0.7, metallic=0.1)
- "wood": 木质 (roughness=0.9, metallic=0.0)
- "concrete": 混凝土 (roughness=0.95, metallic=0.0)
- "glass": 玻璃 (roughness=0.2, metallic=0.1)
- "rubber": 橡胶 (roughness=0.85, metallic=0.0)
- "fabric": 织物 (roughness=0.9, metallic=0.0)

## 位置规则
- 所有 position 相对于物体的几何中心 (0, 0, 0)
- Y轴向上、X轴向右、Z轴向前
- 所有几何体的总体尺寸应尽量接近给定的白盒尺寸范围

## 输出格式（严格 JSON）
{
  "description": "简短描述",
  "primitives": [
    {
      "type": "box",
      "size": [w, h, d],
      "position": [x, y, z],
      "color": "#rrggbb",
      "material": "分类名"
    }
  ]
}"""

const FEW_SHOT = [
	{
		"input": "车 (4×1.8×1.5)",
		"output": {
			"description": "轿车",
			"primitives": [
				{"type": "box", "size": [4.0, 0.7, 1.8], "position": [0, 0.75, 0], "color": "#4488cc", "material": "metal"},
				{"type": "box", "size": [2.0, 0.5, 1.7], "position": [-0.4, 1.35, 0], "color": "#88bbee", "material": "glass"},
				{"type": "cylinder", "radius": 0.3, "height": 0.25, "position": [-1.2, 0.15, 0.7], "color": "#222", "material": "rubber"},
				{"type": "cylinder", "radius": 0.3, "height": 0.25, "position": [-1.2, 0.15, -0.7], "color": "#222", "material": "rubber"},
				{"type": "cylinder", "radius": 0.3, "height": 0.25, "position": [1.2, 0.15, 0.7], "color": "#222", "material": "rubber"},
				{"type": "cylinder", "radius": 0.3, "height": 0.25, "position": [1.2, 0.15, -0.7], "color": "#222", "material": "rubber"}
			]
		}
	},
	{
		"input": "木箱 (1×1×1)",
		"output": {
			"description": "木箱",
			"primitives": [
				{"type": "box", "size": [1.0, 0.95, 1.0], "position": [0, 0.5, 0], "color": "#8c613d", "material": "wood"},
				{"type": "box", "size": [1.02, 0.05, 1.02], "position": [0, 1.0, 0], "color": "#a0704d", "material": "wood"},
				{"type": "box", "size": [0.06, 0.08, 0.06], "position": [0.47, 0.0, 0.47], "color": "#8899aa", "material": "metal"},
				{"type": "box", "size": [0.06, 0.08, 0.06], "position": [-0.47, 0.0, 0.47], "color": "#8899aa", "material": "metal"},
				{"type": "box", "size": [0.06, 0.08, 0.06], "position": [0.47, 0.0, -0.47], "color": "#8899aa", "material": "metal"},
				{"type": "box", "size": [0.06, 0.08, 0.06], "position": [-0.47, 0.0, -0.47], "color": "#8899aa", "material": "metal"}
			]
		}
	},
	{
		"input": "混凝土掩体 (1.2×0.8×1.8)",
		"output": {
			"description": "混凝土掩体",
			"primitives": [
				{"type": "box", "size": [1.2, 0.8, 1.8], "position": [0, 0.5, 0], "color": "#a6a399", "material": "concrete"},
				{"type": "wedge", "size": [1.0, 0.3, 1.6], "position": [0, 1.05, 0], "color": "#969389", "material": "concrete"},
				{"type": "box", "size": [0.3, 1.1, 0.12], "position": [-0.6, 0.65, 0.3], "color": "#b6b3a9", "material": "concrete"},
				{"type": "box", "size": [0.3, 1.1, 0.12], "position": [-0.6, 0.65, -0.3], "color": "#b6b3a9", "material": "concrete"}
			]
		}
	},
	{
		"input": "木门 (0.8×0.08×2.2)",
		"output": {
			"description": "木门",
			"primitives": [
				{"type": "box", "size": [0.8, 0.07, 2.2], "position": [0, 1.1, 0], "color": "#8c613d", "material": "wood"},
				{"type": "box", "size": [0.84, 0.1, 2.24], "position": [0, 1.1, 0], "color": "#7a5535", "material": "wood"},
				{"type": "sphere", "radius": 0.04, "position": [0.25, 1.08, 0], "color": "#cccc99", "material": "metal"}
			]
		}
	},
	{
		"input": "石柱 (0.5×0.5×3)",
		"output": {
			"description": "石柱",
			"primitives": [
				{"type": "box", "size": [0.5, 2.6, 0.5], "position": [0, 1.5, 0], "color": "#c8bfb0", "material": "stone"},
				{"type": "box", "size": [0.7, 0.2, 0.7], "position": [0, 2.9, 0], "color": "#d8cfc0", "material": "stone"},
				{"type": "box", "size": [0.65, 0.2, 0.65], "position": [0, 0.1, 0], "color": "#d8cfc0", "material": "stone"}
			]
		}
	}
]


static func build_messages(user_prompt: String) -> Array:
	var messages = []
	messages.append({"role": "system", "content": SYSTEM_PROMPT})

	for example in FEW_SHOT:
		messages.append({"role": "user", "content": example["input"]})
		messages.append({"role": "assistant", "content": JSON.stringify(example["output"])})

	messages.append({"role": "user", "content": user_prompt})
	return messages


static func build_user_prompt(description: String, dimensions: Vector3) -> String:
	return description + " (%.1f×%.1f×%.1f)" % [dimensions.x, dimensions.y, dimensions.z]
