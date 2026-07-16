extends CanvasLayer

const GAME_W := 320
const GAME_H := 240
const TITLE_FADE   := 1.0
const TITLE_HOLD   := 2.0
const CREDITS_FADE := 1.0
const LOGO_SIZE     := 64.0
const STUDIO_NAME   := "YellowDuck Studio"
const CREDITS_TEXT  := "Producer / Programmer: FENG JIAQI (Jacky)\nMap & Art: LIM ZHI YUAN (Zee)"

var _overlay : ColorRect
var _label   : Label
var _logo    : TextureRect
var _studio  : Label
var _credits : Label

func _ready() -> void:
	layer        = 25
	process_mode = Node.PROCESS_MODE_ALWAYS

	var pf := load("res://Scenes/Fonts/pixel.ttf") as FontFile

	_overlay          = ColorRect.new()
	_overlay.color    = Color.BLACK
	_overlay.position = Vector2.ZERO
	_overlay.size     = Vector2(GAME_W, GAME_H)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.modulate.a   = 0.0
	add_child(_overlay)

	_label = _make_label("YAKO", 16, pf, Vector2.ZERO, Vector2(GAME_W, GAME_H))
	add_child(_label)

	var logo_tex := load("res://Scenes/Assets/UI/YellowDuck.jpg") as Texture2D
	_logo = TextureRect.new()
	_logo.texture = logo_tex
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_logo.position = Vector2((GAME_W - LOGO_SIZE) / 2.0, 28.0)
	_logo.size     = Vector2(LOGO_SIZE, LOGO_SIZE)
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_logo.modulate.a = 0.0
	add_child(_logo)

	_studio = _make_label(STUDIO_NAME, 8, pf, Vector2(0.0, 94.0), Vector2(GAME_W, 16.0))
	add_child(_studio)

	_credits = _make_label(CREDITS_TEXT, 6, pf, Vector2(0.0, 110.0), Vector2(GAME_W, GAME_H - 110.0))
	add_child(_credits)

func _make_label(text: String, font_size: int, pf: FontFile, pos: Vector2, size: Vector2) -> Label:
	var label := Label.new()
	label.text     = text
	label.position = pos
	label.size     = size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.modulate.a   = 0.0
	label.z_index      = 1
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_font_size_override("font_size", font_size)
	if pf:
		label.add_theme_font_override("font", pf)
	return label

func play() -> void:
	_overlay.modulate.a = 1.0
	await get_tree().create_timer(0.1).timeout

	var tw := create_tween()
	tw.tween_property(_label, "modulate:a", 1.0, TITLE_FADE)
	await tw.finished

	await get_tree().create_timer(TITLE_HOLD).timeout

	tw = create_tween()
	tw.tween_property(_label, "modulate:a", 0.0, CREDITS_FADE)
	await tw.finished

	tw = create_tween()
	tw.tween_property(_logo, "modulate:a", 1.0, CREDITS_FADE)
	tw.parallel().tween_property(_studio, "modulate:a", 1.0, CREDITS_FADE)
	tw.parallel().tween_property(_credits, "modulate:a", 1.0, CREDITS_FADE)
	await tw.finished
