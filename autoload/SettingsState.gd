extends Node

const SAVE_PATH := "user://settings.cfg"

const LANGUAGES := ["en", "zh", "ja"]

const FONT_PATHS := {
	"en": "res://Scenes/Fonts/pixel.ttf",
	"zh": "res://Scenes/Fonts/ark-pixel-16px-proportional-zh_cn.ttf",
	"ja": "res://Scenes/Fonts/ark-pixel-16px-proportional-ja.ttf",
}

const LANGUAGE_NAMES := {
	"en": "English",
	"zh": "中文",
	"ja": "日本語",
}

signal language_changed(locale: String)

var master_volume : float = 1.0
var language : String = "en"

func _ready() -> void:
	_load()
	_apply_volume()
	_apply_language()

func set_master_volume(v: float) -> void:
	master_volume = clampf(v, 0.0, 1.0)
	_apply_volume()
	_save()

func set_language(locale: String) -> void:
	language = locale
	_apply_language()
	_save()
	language_changed.emit(language)

func cycle_language() -> void:
	var idx := LANGUAGES.find(language)
	set_language(LANGUAGES[(idx + 1) % LANGUAGES.size()])

func language_name() -> String:
	return LANGUAGE_NAMES.get(language, language)

func get_active_font() -> Font:
	return load(FONT_PATHS.get(language, FONT_PATHS["en"])) as Font

# The Ark Pixel CJK fonts are 16px-grid pixel fonts — rendering them at the
# small sizes tuned for pixel.ttf (6-10px) scales them down non-integrally
# and blurs them. Bucket every English size into a clean multiple of 16
# instead; English keeps its original tuned size unchanged.
func get_active_font_size(base_size: int) -> int:
	if language == "en":
		return base_size
	return 16 if base_size <= 10 else 32

# For screens that want English and CJK to look the same size on screen —
# pixel.ttf and the Ark Pixel fonts don't share a common em-square design, so
# the same numeric font_size renders very differently between them (pixel.ttf
# at 16 came out much larger/wider than the CJK fonts at 16, confirmed by
# direct visual comparison, not just a hunch). Pass the two sizes tuned to
# look equivalent instead of assuming one number works for both.
func get_display_font_size(en_size: int, cjk_size: int) -> int:
	return en_size if language == "en" else cjk_size

func _apply_volume() -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, -80.0 if master_volume <= 0.0 else linear_to_db(master_volume))

func _apply_language() -> void:
	TranslationServer.set_locale(language)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		master_volume = cfg.get_value("settings", "master_volume", 1.0)
		language = cfg.get_value("settings", "language", "en")

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "master_volume", master_volume)
	cfg.set_value("settings", "language", language)
	cfg.save(SAVE_PATH)
