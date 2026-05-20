@tool
class_name main_dock
extends Control

const PresetLib = preload("res://addons/ph_generator/presets/library.gd")
const ConfigDialog = preload("res://addons/ph_generator/config/config_dialog.gd")

var _generator
var _config
var _current_ph_node: Node3D = null
var _description_input: TextEdit
var _dim_w
var _dim_h
var _dim_d
var _auto_select_box: CheckBox
var _json_display: TextEdit
var _status_label: RichTextLabel
var _generate_btn: Button
var _export_glb_btn: Button
var _export_fbx_btn: Button
var _preset_dropdown: OptionButton


func setup(generator) -> void:
	_generator = generator
	_config = generator.get_config()
	_generator.status_update.connect(_on_status)
	_generator.ph_generated.connect(_on_ph_generated)
	_generator.ph_exported.connect(_on_exported)
	_build_ui()


func _build_ui() -> void:
	custom_minimum_size = Vector2(300, 500)
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL

	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	var title = Label.new()
	title.text = "PH Generator"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	var settings_btn = Button.new()
	settings_btn.text = "⚙ 设置 (API Key)"
	settings_btn.pressed.connect(_open_settings)
	settings_btn.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.add_child(settings_btn)

	vbox.add_child(_separator())

	var preset_label = Label.new()
	preset_label.text = "快速模板:"
	vbox.add_child(preset_label)

	_preset_dropdown = OptionButton.new()
	_preset_dropdown.size_flags_horizontal = SIZE_EXPAND_FILL
	_preset_dropdown.add_item("-- 选择预设 --", 0)
	for key in PresetLib.get_preset_keys():
		_preset_dropdown.add_item(key)
	_preset_dropdown.item_selected.connect(_on_preset_selected)
	vbox.add_child(_preset_dropdown)

	vbox.add_child(_separator())

	var desc_label = Label.new()
	desc_label.text = "物件描述 (自然语言):"
	vbox.add_child(desc_label)

	_description_input = TextEdit.new()
	_description_input.custom_minimum_size = Vector2(0, 60)
	_description_input.placeholder_text = "例如: 轿车 (4×1.8×1.5)"
	_description_input.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_description_input.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.add_child(_description_input)

	var dims_label = Label.new()
	dims_label.text = "尺寸 (X=长, Y=高, Z=深):"
	vbox.add_child(dims_label)

	var dims_row = HBoxContainer.new()
	_dim_w = _make_spinbox("X", 1.0, 0.01, 100.0)
	_dim_h = _make_spinbox("Y", 1.0, 0.01, 100.0)
	_dim_d = _make_spinbox("Z", 1.0, 0.01, 100.0)
	dims_row.add_child(_dim_w)
	dims_row.add_child(_dim_h)
	dims_row.add_child(_dim_d)
	vbox.add_child(dims_row)

	_auto_select_box = CheckBox.new()
	_auto_select_box.text = "从选中节点读取尺寸"
	_auto_select_box.button_pressed = _config.auto_select_whitebox
	_auto_select_box.toggled.connect(_on_auto_select_toggled)
	vbox.add_child(_auto_select_box)

	_generate_btn = Button.new()
	_generate_btn.text = "AI 生成 PH"
	_generate_btn.size_flags_horizontal = SIZE_EXPAND_FILL
	_generate_btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	_generate_btn.pressed.connect(_on_generate_pressed)
	vbox.add_child(_generate_btn)

	vbox.add_child(_separator())

	var json_label = Label.new()
	json_label.text = "LLM 解析结果 (可编辑):"
	vbox.add_child(json_label)

	_json_display = TextEdit.new()
	_json_display.custom_minimum_size = Vector2(0, 150)
	_json_display.placeholder_text = "这里显示 AI 解析后的几何结构..."
	_json_display.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_json_display.size_flags_horizontal = SIZE_EXPAND_FILL
	vbox.add_child(_json_display)

	var export_row = HBoxContainer.new()
	_export_glb_btn = Button.new()
	_export_glb_btn.text = "导出 .glb"
	_export_glb_btn.disabled = true
	_export_glb_btn.pressed.connect(_on_export_glb)
	export_row.add_child(_export_glb_btn)

	_export_fbx_btn = Button.new()
	_export_fbx_btn.text = "导出 .glb + .fbx"
	_export_fbx_btn.disabled = true
	_export_fbx_btn.pressed.connect(_on_export_fbx)
	export_row.add_child(_export_fbx_btn)

	vbox.add_child(export_row)

	vbox.add_child(_separator())

	_status_label = RichTextLabel.new()
	_status_label.custom_minimum_size = Vector2(0, 80)
	_status_label.bbcode_enabled = true
	_status_label.scroll_following = true
	_status_label.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.add_child(_status_label)

	_update_dimensions_from_selection()


func _make_spinbox(label: String, default_val: float, step_val: float, max_val: float):
	var row = HBoxContainer.new()
	var lbl = Label.new()
	lbl.text = label + ": "
	lbl.custom_minimum_size = Vector2(22, 0)
	row.add_child(lbl)
	var spin = SpinBox.new()
	spin.min_value = 0.01
	spin.max_value = max_val
	spin.step = step_val
	spin.value = default_val
	spin.size_flags_horizontal = SIZE_EXPAND_FILL
	row.add_child(spin)
	row.size_flags_horizontal = SIZE_EXPAND_FILL
	return row


func _separator() -> HSeparator:
	var sep = HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 4)
	return sep


func _on_status(message: String) -> void:
	_status_label.append_text("\n" + message)


func _on_preset_selected(idx: int) -> void:
	if idx == 0:
		return
	var key = _preset_dropdown.get_item_text(idx)
	var preset = PresetLib.get_preset(key)
	_json_display.text = JSON.stringify(preset, "\t")
	_description_input.text = preset.get("description", "")
	_status_label.append_text("\n已加载预设: " + key)


func _on_auto_select_toggled(pressed: bool) -> void:
	_config.auto_select_whitebox = pressed
	if pressed:
		_update_dimensions_from_selection()


func _update_dimensions_from_selection() -> void:
	if not _generator:
		return
	var info = _generator.get_selected_node_bbox()
	var dims = info.get("dimensions", Vector3(1, 1, 1))
	_dim_w.get_child(1).value = dims.x
	_dim_h.get_child(1).value = dims.y
	_dim_d.get_child(1).value = dims.z


func _get_dimensions_vector() -> Vector3:
	return Vector3(
		_dim_w.get_child(1).value,
		_dim_h.get_child(1).value,
		_dim_d.get_child(1).value
	)


func _on_generate_pressed() -> void:
	_status_label.text = ""

	if _auto_select_box.button_pressed:
		_update_dimensions_from_selection()

	var desc = _description_input.text
	var dims = _get_dimensions_vector()
	_generate_btn.disabled = true
	_export_glb_btn.disabled = true
	_export_fbx_btn.disabled = true
	_current_ph_node = null
	_generator.request_generate(desc, dims)


func _on_ph_generated(node: Node3D) -> void:
	_current_ph_node = node
	_generate_btn.disabled = false
	_export_glb_btn.disabled = false
	_export_fbx_btn.disabled = false

	var editor_interface = _generator._editor_plugin.get_editor_interface()
	editor_interface.edit_node(node)
	editor_interface.get_selection().clear()
	editor_interface.get_selection().add_node(node)


func _on_export_glb() -> void:
	if _current_ph_node == null:
		return
	_generator.export_glb(_current_ph_node)


func _on_export_fbx() -> void:
	if _current_ph_node == null:
		return
	var saved_fbx = _config.export_fbx
	_config.export_fbx = true
	_generator.export_glb(_current_ph_node)
	_config.export_fbx = saved_fbx


func _on_exported(glb_path: String, fbx_path: String) -> void:
	if fbx_path:
		_status_label.append_text("\n双格式导出完成!")


func _open_settings() -> void:
	var dialog = ConfigDialog.new()
	dialog.setup(_config)
	dialog.settings_saved.connect(func():
		_status_label.append_text("\n设置已保存")
	)
	var editor = _generator._editor_plugin.get_editor_interface().get_base_control()
	editor.add_child(dialog)
	dialog.popup_centered()
