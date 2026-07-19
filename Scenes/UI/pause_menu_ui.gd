extends CanvasLayer

const GAME_W := 320
const GAME_H := 240
const MAIN_MENU_SCENE := "res://Scenes/UI/MainMenu.tscn"

var _open : bool = false
var _settings_instance : CanvasLayer

var _paused_label   : Label
var _resume_button   : Button
var _settings_button : Button
var _main_menu_button : Button
var _quit_button      : Button

func _ready() -> void:
	layer        = 15
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible      = false

	var dim := ColorRect.new()
	dim.color        = Color(0, 0, 0, 0.6)
	dim.position     = Vector2.ZERO
	dim.size         = Vector2(GAME_W, GAME_H)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	_paused_label    = _make_label("Paused", 16, Vector2(0, 45), Vector2(GAME_W, 24))
	_resume_button   = _make_button("Resume",    Vector2(110, 110), Vector2(100, 18), _on_resume_pressed)
	_settings_button = _make_button("Settings",  Vector2(110, 135), Vector2(100, 18), _on_settings_pressed)
	_main_menu_button = _make_button("Main Menu", Vector2(110, 160), Vector2(100, 18), _on_main_menu_pressed)
	_quit_button      = _make_button("Quit",      Vector2(110, 185), Vector2(100, 18), _on_quit_pressed)
	add_child(_paused_label)
	add_child(_resume_button)
	add_child(_settings_button)
	add_child(_main_menu_button)
	add_child(_quit_button)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if _open:
		close()
	else:
		open()

func open() -> void:
	_open   = true
	visible = true
	get_tree().paused = true
	Input.mouse_mode  = Input.MOUSE_MODE_VISIBLE
	_refresh_text()

func close() -> void:
	_open   = false
	visible = false
	get_tree().paused = false
	Input.mouse_mode  = Input.MOUSE_MODE_CAPTURED

func _refresh_text() -> void:
	var pf := SettingsState.get_active_font()
	_paused_label.add_theme_font_override("font", pf)
	_paused_label.add_theme_font_size_override("font_size", SettingsState.get_active_font_size(16))
	_paused_label.text = tr("Paused")
	for btn: Button in [_resume_button, _settings_button, _main_menu_button, _quit_button]:
		btn.add_theme_font_override("font", pf)
		btn.add_theme_font_size_override("font_size", SettingsState.get_active_font_size(10))
	_resume_button.text    = tr("Resume")
	_settings_button.text  = tr("Settings")
	_main_menu_button.text = tr("Main Menu")
	_quit_button.text      = tr("Quit")

func _on_resume_pressed() -> void:
	close()

func _on_settings_pressed() -> void:
	if _settings_instance != null:
		return
	_settings_instance = load("res://Scenes/UI/settings_menu_ui.gd").new()
	add_child(_settings_instance)
	_settings_instance.tree_exited.connect(func() -> void:
		_settings_instance = null
		_refresh_text()
	)

func _on_main_menu_pressed() -> void:
	close()
	SceneManager.change_scene(MAIN_MENU_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

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
