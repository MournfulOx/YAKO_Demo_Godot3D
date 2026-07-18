extends CanvasLayer

const GAME_W := 320
const GAME_H := 240
const MAIN_MENU_SCENE := "res://Scenes/UI/MainMenu.tscn"

var _open : bool = false

func _ready() -> void:
	layer        = 15
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible      = false

	var pf := load("res://Scenes/Fonts/pixel.ttf") as FontFile

	var dim := ColorRect.new()
	dim.color        = Color(0, 0, 0, 0.6)
	dim.position     = Vector2.ZERO
	dim.size         = Vector2(GAME_W, GAME_H)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	add_child(_make_label("Paused", 16, pf, Vector2(0, 50), Vector2(GAME_W, 24)))
	add_child(_make_button("Resume",    pf, Vector2(110, 120), Vector2(100, 18), _on_resume_pressed))
	add_child(_make_button("Main Menu", pf, Vector2(110, 145), Vector2(100, 18), _on_main_menu_pressed))
	add_child(_make_button("Quit",      pf, Vector2(110, 170), Vector2(100, 18), _on_quit_pressed))

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

func close() -> void:
	_open   = false
	visible = false
	get_tree().paused = false
	Input.mouse_mode  = Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed() -> void:
	close()

func _on_main_menu_pressed() -> void:
	close()
	SceneManager.change_scene(MAIN_MENU_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _make_label(text: String, font_size: int, pf: FontFile, pos: Vector2, size: Vector2) -> Label:
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
	if pf:
		label.add_theme_font_override("font", pf)
	return label

func _make_button(text: String, pf: FontFile, pos: Vector2, size: Vector2, callback: Callable) -> Button:
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
	if pf:
		btn.add_theme_font_override("font", pf)
	btn.pressed.connect(callback)
	return btn
