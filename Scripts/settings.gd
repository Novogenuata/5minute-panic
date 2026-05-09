extends Control

@onready var lang_manager = get_node("/root/LanguageManager")
@onready var en_button = $TextureRect/VBoxContainer/HBoxContainer/VBoxContainer2/en
@onready var fr_button = $TextureRect/VBoxContainer/HBoxContainer/VBoxContainer2/fr

func _ready() -> void:
	_update_language_buttons()
	lang_manager.language_changed.connect(_update_language_buttons)

func _on_fs_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_wn_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_ts_pressed() -> void:
	SceneManager.change_scene("res://Scenes/titlescreen.tscn")

func _on_en_pressed() -> void:
	lang_manager.set_language("en")

func _on_fr_pressed() -> void:
	lang_manager.set_language("fr")

func _update_language_buttons(_lang: String = "") -> void:
	if en_button and fr_button:
		en_button.button_pressed = (lang_manager.current_language == "en")
		fr_button.button_pressed = (lang_manager.current_language == "fr")
