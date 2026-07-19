extends CanvasLayer

const GAME_W := 320
const GAME_H := 240

var _title_label    : Label
var _volume_label   : Label
var _language_label : Label
var _lang_button    : Button
var _back_button    : Button

func _ready() -> void:
	layer        = 16
	process_mode = Node.PROCESS_MODE_ALWAYS

	var dim := ColorRect.new()
	dim.color        = Color(0, 0, 0, 0.75)
	dim.position     = Vector2.ZERO
	dim.size         = Vector2(GAME_W, GAME_H)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	_title_label    = _make_label("Settings", 16, Vector2(0, 24), Vector2(GAME_W, 24))
	_volume_label   = _make_label("Volume", 8, Vector2(60, 80), Vector2(80, 16))
	_language_label = _make_label("Language", 8, Vector2(60, 130), Vector2(80, 16))
	add_child(_title_label)
	add_child(_volume_label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step      = 0.05
	slider.value     = SettingsState.master_volume
	slider.position  = Vector2(60, 100)
	slider.size      = Vector2(200, 16)
	slider.value_changed.connect(_on_volume_changed)
	add_child(slider)

	add_child(_language_label)
	_lang_button = _make_button(SettingsState.language_name(), Vector2(110, 150), Vector2(100, 18), _on_language_pressed)
	add_child(_lang_button)

	_back_button = _make_button("Back", Vector2(110, 190), Vector2(100, 18), _on_back_pressed)
	add_child(_back_button)

	_refresh_text()

func _refresh_text() -> void:
	var pf := SettingsState.get_active_font()
	_title_label.add_theme_font_override("font", pf)
	_title_label.add_theme_font_size_override("font_size", SettingsState.get_active_font_size(16))
	_title_label.text = tr("Settings")

	for label: Label in [_volume_label, _language_label]:
		label.add_theme_font_override("font", pf)
		label.add_theme_font_size_override("font_size", SettingsState.get_active_font_size(8))
	_volume_label.text   = tr("Volume")
	_language_label.text = tr("Language")

	for btn: Button in [_lang_button, _back_button]:
		btn.add_theme_font_override("font", pf)
		btn.add_theme_font_size_override("font_size", SettingsState.get_active_font_size(10))
	_back_button.text = tr("Back")
	_lang_button.text = SettingsState.language_name()

func _on_volume_changed(v: float) -> void:
	SettingsState.set_master_volume(v)

func _on_language_pressed() -> void:
	SettingsState.cycle_language()
	_refresh_text()

func _on_back_pressed() -> void:
	queue_free()

func _make_label(text: String, font_size: int, pos: Vector2, size: Vector2) -> Label:
	var label := Label.new()
	label.text     = text
	label.position = pos
	label.size     = size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _make_button(text: String, pos: Vector2, size: Vector2, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text     = text
	btn.position = pos
	btn.size     = size
	btn.flat     = true
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.62, 0.18))
	btn.add_theme_color_override("font_outline_color", Color.BLACK)
	btn.add_theme_constant_override("outline_size", 1)
	btn.add_theme_font_size_override("font_size", 10)
	btn.pressed.connect(callback)
	return btn
