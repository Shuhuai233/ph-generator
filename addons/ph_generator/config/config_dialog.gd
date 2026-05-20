@tool
class_name config_dialog
extends AcceptDialog

signal settings_saved()

var _config: config_manager

var _endpoint_input: LineEdit
var _key_input: LineEdit
var _model_input: LineEdit
var _temp_spin: SpinBox
var _fbx_check: CheckBox
var _export_dir_input: LineEdit


func setup(cm: config_manager) -> void:
	_config = cm
	_populate_form()
	_load_values()


func _populate_form() -> void:
	title = "PH Generator 设置"
	ok_button_text = "保存"
	cancel_button_text = "取消"
	size = Vector2(550, 400)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	vbox.add_child(_make_section("LLM API 配置"))
	_endpoint_input = LineEdit.new()
	vbox.add_child(_make_row("Endpoint:", _endpoint_input))
	_endpoint_input.placeholder_text = "https://api.openai.com/v1/chat/completions"
	_key_input = LineEdit.new()
	vbox.add_child(_make_row("API Key:", _key_input))
	_key_input.secret = true
	_key_input.placeholder_text = "sk-..."
	_model_input = LineEdit.new()
	vbox.add_child(_make_row("Model:", _model_input))
	_model_input.placeholder_text = "gpt-4o"

	var model_hint = Label.new()
	model_hint.text = "支持 OpenAI 兼容接口 (DeepSeek/Claude/GLM 等)"
	model_hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(model_hint)

	vbox.add_child(_make_section("生成参数"))
	var temp_row = HBoxContainer.new()
	temp_row.add_child(Label.new())
	temp_row.get_child(0).text = "Temperature:"
	_temp_spin = SpinBox.new()
	_temp_spin.min_value = 0.0
	_temp_spin.max_value = 2.0
	_temp_spin.step = 0.1
	_temp_spin.value = 0.3
	temp_row.add_child(_temp_spin)
	vbox.add_child(temp_row)

	vbox.add_child(_make_section("导出设置"))
	_fbx_check = CheckBox.new()
	_fbx_check.text = "自动导出 FBX（需 Python 环境）"
	vbox.add_child(_fbx_check)
	_export_dir_input = LineEdit.new()
	vbox.add_child(_make_row("导出目录:", _export_dir_input))
	_export_dir_input.text = "res://exports"

	add_child(vbox)
	confirmed.connect(_on_save)


func _load_values() -> void:
	_endpoint_input.text = _config.api_endpoint
	_key_input.text = _config.api_key
	_model_input.text = _config.model
	_temp_spin.value = _config.temperature
	_fbx_check.button_pressed = _config.export_fbx
	_export_dir_input.text = _config.export_dir


func _on_save() -> void:
	_config.api_endpoint = _endpoint_input.text
	_config.api_key = _key_input.text
	_config.model = _model_input.text
	_config.temperature = _temp_spin.value
	_config.export_fbx = _fbx_check.button_pressed
	_config.export_dir = _export_dir_input.text
	_config.save()
	settings_saved.emit()


func _make_section(title_text: String) -> Label:
	var label = Label.new()
	label.text = title_text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0))
	return label


func _make_row(label_text: String, input_control: Control) -> HBoxContainer:
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(100, 0)
	row.add_child(label)
	input_control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(input_control)
	return row
