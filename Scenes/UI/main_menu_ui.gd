extends CanvasLayer

const GAME_W := 320
const GAME_H := 240
const START_SCENE := "res://Scenes/UI/OpeningQuote.tscn"

func _ready() -> void:
	layer = 10
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var pf := load("res://Scenes/Fonts/pixel.ttf") as FontFile

	add_child(_make_label("YAKO", 24, pf, Vector2(0, 36), Vector2(GAME_W, 32)))
	add_child(_make_button("Start", pf, Vector2(110, 150), Vector2(100, 18), _on_start_pressed))
	add_child(_make_button("Quit", pf, Vector2(110, 175), Vector2(100, 18), _on_quit_pressed))

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

func _on_start_pressed() -> void:
	SceneManager.change_scene(START_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()
