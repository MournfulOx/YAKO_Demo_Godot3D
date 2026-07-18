extends CanvasLayer

const GAME_W := 320
const FADE_IN_DURATION  := 0.3
const HOLD_DURATION     := 2.2
const FADE_OUT_DURATION := 0.6

var _label : Label
var _tween : Tween

func _ready() -> void:
	layer = 6

	_label = Label.new()
	_label.position = Vector2(0, 18)
	_label.size     = Vector2(GAME_W, 20)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_color_override("font_color", Color(0.96, 0.78, 0.26))
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 1)
	_label.add_theme_font_size_override("font_size", 7)
	var pf := load("res://Scenes/Fonts/pixel.ttf") as FontFile
	if pf:
		_label.add_theme_font_override("font", pf)
	_label.modulate.a = 0.0
	add_child(_label)

	YellowDuckState.duck_collected.connect(_on_duck_collected)

func _on_duck_collected(count: int, total: int) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	if count >= total:
		_label.text = "All %d Yellow Ducks found." % total
	else:
		_label.text = "Yellow Duck found. %d / %d" % [count, total]
	_label.modulate.a = 0.0

	_tween = create_tween()
	_tween.tween_property(_label, "modulate:a", 1.0, FADE_IN_DURATION)
	_tween.tween_interval(HOLD_DURATION)
	_tween.tween_property(_label, "modulate:a", 0.0, FADE_OUT_DURATION)
