@tool
class_name LLMClient
extends HTTPRequest

const PromptMgr = preload("res://addons/ph_generator/ai/prompt_mgr.gd")
const Parser = preload("res://addons/ph_generator/ai/parser.gd")

signal response_received(parsed_json: Dictionary)
signal error_occurred(message: String)

var _config


func set_config(cm) -> void:
	_config = cm
	timeout = 60


func request_ph_json(description: String, dimensions: Vector3) -> void:
	if _config.api_key.is_empty():
		error_occurred.emit("未配置 API Key，请在设置中填写")
		return

	var prompt = PromptMgr.build_user_prompt(description, dimensions)
	var messages = PromptMgr.build_messages(prompt)

	var body = JSON.stringify({
		"model": _config.model,
		"messages": messages,
		"temperature": _config.temperature,
		"max_tokens": 2048,
		"response_format": {"type": "json_object"},
	})

	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + _config.api_key,
	]

	var error = request(_config.api_endpoint, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		error_occurred.emit("HTTP 请求失败: " + str(error))
		return

	request_completed.connect(_on_response, CONNECT_ONE_SHOT)


func _on_response(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		var err_body = body.get_string_from_utf8()
		error_occurred.emit("API 错误 (" + str(response_code) + "): " + err_body)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		error_occurred.emit("无法解析 API 响应")
		return

	var content = json.get("choices", [{}])[0].get("message", {}).get("content", "")
	if content.is_empty():
		error_occurred.emit("API 返回内容为空")
		return

	var parsed = Parser.parse_response(content)
	if parsed.is_empty():
		error_occurred.emit("无法解析 PH 结构: " + content)
		return

	response_received.emit(parsed)
