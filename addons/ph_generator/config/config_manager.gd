@tool
class_name config_manager
extends RefCounted

const CONFIG_PATH = "user://ph_generator_config.cfg"

var api_endpoint: String = "https://api.openai.com/v1/chat/completions"
var api_key: String = ""
var model: String = "gpt-4o"
var temperature: float = 0.3
var auto_select_whitebox: bool = true
var export_fbx: bool = false
var export_dir: String = "res://exports"

func save() -> void:
	var config = ConfigFile.new()
	config.set_value("api", "endpoint", api_endpoint)
	config.set_value("api", "key", api_key)
	config.set_value("api", "model", model)
	config.set_value("api", "temperature", temperature)
	config.set_value("export", "export_fbx", export_fbx)
	config.set_value("export", "export_dir", export_dir)
	config.set_value("editor", "auto_select", auto_select_whitebox)
	config.save(CONFIG_PATH)

func load() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		api_endpoint = config.get_value("api", "endpoint", api_endpoint)
		api_key = config.get_value("api", "key", api_key)
		model = config.get_value("api", "model", model)
		temperature = config.get_value("api", "temperature", temperature)
		export_fbx = config.get_value("export", "export_fbx", export_fbx)
		export_dir = config.get_value("export", "export_dir", export_dir)
		auto_select_whitebox = config.get_value("editor", "auto_select", auto_select_whitebox)
