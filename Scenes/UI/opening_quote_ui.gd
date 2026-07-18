extends CanvasLayer

const GAME_W := 320
const GAME_H := 240
const QUOTE_HOLD := 12.0
const FADE_DURATION := 1.0
const NEXT_SCENE := "res://Scenes/Maps/Map_01_ConvenienceStore.tscn"
const QUOTE_TEXT := "\"I am like a desert owl,\nlike an owl among the ruins.\nI lie awake; I have become\nlike a bird alone on a rooftop.\"\n\n-- Psalm 102:6-7"

var _overlay : ColorRect
var _label   : Label

func _ready() -> void:
	layer        = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var pf := load("res://Scenes/Fonts/pixel.ttf") as FontFile

	_overlay          = ColorRect.new()
	_overlay.color    = Color.BLACK
	_overlay.position = Vector2.ZERO
	_overlay.size     = Vector2(GAME_W, GAME_H)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	_label = Label.new()
	_label.text     = QUOTE_TEXT
	_label.position = Vector2(10, 0)
	_label.size     = Vector2(GAME_W - 20, GAME_H)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_color_override("font_color", Color.WHITE)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 1)
	_label.add_theme_font_size_override("font_size", 6)
	if pf:
		_label.add_theme_font_override("font", pf)
	add_child(_label)

	await get_tree().create_timer(QUOTE_HOLD).timeout

	var tw := create_tween()
	tw.tween_property(_label, "modulate:a", 0.0, FADE_DURATION)
	await tw.finished

	SceneManager.change_scene(NEXT_SCENE)
