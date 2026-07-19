extends CanvasLayer

const GAME_W := 320
const GAME_H := 240
const START_SCENE := "res://Scenes/UI/OpeningQuote.tscn"

var _settings_instance : CanvasLayer

var _title_label     : Label
var _start_button    : Button
var _settings_button  : Button
var _quit_button      : Button

func _ready() -> void:
	layer = 10
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_title_label     = _make_label("YAKO", 24, Vector2(0, 36), Vector2(GAME_W, 32))
	_start_button    = _make_button("Start",    Vector2(110, 150), Vector2(100, 18), _on_start_pressed)
	_settings_button = _make_button("Settings", Vector2(110, 175), Vector2(100, 18), _on_settings_pressed)
	_quit_button     = _make_button("Quit",     Vector2(110, 200), Vector2(100, 18), _on_quit_pressed)
	add_child(_title_label)
	add_child(_start_button)
	add_child(_settings_button)
	add_child(_quit_button)
	_refresh_text()

func _refresh_text() -> void:
	var pf := SettingsState.get_active_font()
	_title_label.add_theme_font_override("font", pf)
	_title_label.add_theme_font_size_override("font_size", SettingsState.get_active_font_size(24))
	for btn: Button in [_start_button, _settings_button, _quit_button]:
		btn.add_theme_font_override("font", pf)
		btn.add_theme_font_size_override("font_size", SettingsState.get_active_font_size(10))
	_start_button.text    = tr("Start")
	_settings_button.text = tr("Settings")
	_quit_button.text     = tr("Quit")

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

func _on_start_pressed() -> void:
	SceneManager.change_scene(START_SCENE)

func _on_settings_pressed() -> void:
	if _settings_instance != null:
		return
	_settings_instance = load("res://Scenes/UI/settings_menu_ui.gd").new()
	add_child(_settings_instance)
	_settings_instance.tree_exited.connect(func() -> void:
		_settings_instance = null
		_refresh_text()
	)

func _on_quit_pressed() -> void:
	get_tree().quit()
