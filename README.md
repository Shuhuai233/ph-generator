# PH Generator — AI 占位模型生成器

Godot 4.6 Editor Plugin。输入**白盒尺寸 + 物件描述**，调用 LLM 解析 → 程序化生成 Placeholder (PH) 3D 模型。解决关卡策划白盒到场景美术 PH 的纯体力劳动。

## 快速开始

```bash
git clone <this-repo>
# 用 Godot 4.6 打开项目
# 右侧 Dock → ⚙设置 → 填入 API Key
```

## 使用流程

```
白盒方体 → 输入"轿车 (4×1.8×1.5)" → AI 解析 → 生成 PH → 导出 .glb/.fbx
```

| 白盒尺寸 | 描述 | PH 效果 |
|----------|------|---------|
| 4×1.8×1.5 | 轿车 | 车身+车舱+4轮 |
| 1×1×1 | 木箱 | 箱体+箱盖+包角 |
| 1.2×0.8×1.8 | 掩体 | 主体+斜面+护翼 |
| 0.8×0.08×2.2 | 木门 | 门板+门框+把手 |
| 0.5×0.5×3 | 石柱 | 柱身+柱头+柱础 |

## 功能

- **AI 解析**：自然语言 → 几何体组合 JSON（支持 OpenAI/DeepSeek/Claude 等兼容 API）
- **程序化生成**：Box/Cylinder/Sphere/Capsule/Wedge/Plane 六种 primitive 组合
- **离线兜底**：10+ 内置预设模板，无 API 也能用
- **双格式导出**：.glb (原生) + .fbx (需 Python + trimesh)
- **碰撞体 + 标签**：自动附加 CollisionShape3D 和 Label3D

## 架构

```
addons/ph_generator/
├── plugin.gd          # EditorPlugin 入口
├── dock/main_dock.gd  # 编辑器面板
├── core/              # 生成引擎
├── ai/                # LLM 客户端
├── export/            # .glb/.fbx 导出
├── config/            # API Key 管理
├── presets/           # 离线模板库
└── scripts/           # Python 辅助脚本
```

## 配置

支持所有 OpenAI 兼容 API：

| 参数 | 示例 |
|------|------|
| Endpoint | `https://api.openai.com/v1/chat/completions` |
| API Key | `sk-...` |
| Model | `gpt-4o` / `deepseek-chat` |

## 许可证

MIT
