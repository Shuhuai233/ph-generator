@tool
extends Control

## Ultra-minimal dock: one Label saying it works.

func setup(_plugin: EditorPlugin) -> void:
	print("[SmokeDock] setup()")
	custom_minimum_size = Vector2(200, 100)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	var title = Label.new()
	title.text = "PH Smoke Test"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)

	var status = Label.new()
	status.text = "PH Generator is working"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	vbox.add_child(status)

	print("[SmokeDock] setup() done — dock visible")
