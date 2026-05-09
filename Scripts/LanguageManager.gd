extends Node

const LANGUAGES = {
	"en": "English",
	"fr": "French"
}

var current_language: String = "en"

signal language_changed(lang_code: String)

func _ready() -> void:
	var saved = load_language_preference()
	set_language(saved)

func set_language(lang_code: String) -> void:
	if lang_code not in LANGUAGES:
		push_warning("Unknown language: " + lang_code)
		return
	
	current_language = lang_code
	TranslationServer.set_locale(lang_code)
	save_language_preference(lang_code)
	emit_signal("language_changed", lang_code)

func get_current_language() -> String:
	return current_language

func get_language_name(lang_code: String) -> String:
	return LANGUAGES.get(lang_code, "Unknown")

func toggle_language() -> void:
	if current_language == "en":
		set_language("fr")
	else:
		set_language("en")

func save_language_preference(lang_code: String) -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "language", lang_code)
	config.save("user://settings.cfg")

func load_language_preference() -> String:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		return config.get_value("settings", "language", "en")
	return "en"
