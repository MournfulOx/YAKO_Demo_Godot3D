extends CanvasLayer

const GAME_W := 320
const GAME_H := 240

var _overlay : ColorRect
var _label   : Label

func _ready() -> void:
	layer        = 20
	process_mode = Node.PROCESS_MODE_ALWAYS

	_overlay          = ColorRect.new()
	_overlay.color    = Color.BLACK
	_overlay.position = Vector2.ZERO
	_overlay.size     = Vector2(GAME_W, GAME_H)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.modulate.a   = 0.0
	add_child(_overlay)

	_label          = Label.new()
	_label.position = Vector2.ZERO
	_label.size     = Vector2(GAME_W, GAME_H)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.modulate.a   = 0.0
	_label.z_index      = 1
	_label.add_theme_color_override("font_color", Color.WHITE)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 1)
	_label.add_theme_font_size_override("font_size", 6)
	add_child(_label)

func change_scene(path: String) -> void:
	_transition(path)

func _transition(path: String) -> void:
	var tw := create_tween()
	tw.tween_property(_overlay, "modulate:a", 1.0, 0.35)
	await tw.finished

	var show_name := _resolve(path).begins_with("res://Scenes/Maps/")
	if show_name:
		_label.add_theme_font_override("font", SettingsState.get_active_font())
		_label.add_theme_font_size_override("font_size", SettingsState.get_active_font_size(6))
		_label.text       = _parse_name(path)
		_label.modulate.a = 1.0
	await get_tree().create_timer(0.6).timeout

	get_tree().change_scene_to_file(path)
	await get_tree().create_timer(0.1).timeout

	tw = create_tween()
	tw.tween_property(_overlay, "modulate:a", 0.0, 0.45)
	await tw.finished

	if show_name:
		await get_tree().create_timer(1.8).timeout

		tw = create_tween()
		tw.tween_property(_label, "modulate:a", 0.0, 0.6)
		await tw.finished

static func _resolve(path: String) -> String:
	if path.begins_with("uid://"):
		var uid := ResourceUID.text_to_id(path)
		if ResourceUID.has_id(uid):
			return ResourceUID.get_id_path(uid)
	return path

static func _parse_name(path: String) -> String:
	var base  := _resolve(path).get_file().get_basename()
	var parts := base.split("_", false)
	if parts.size() >= 2 and parts[0] == "Map":
		parts.remove_at(0)
		parts.remove_at(0)
	var result := ""
	for p: String in parts:
		for i: int in p.length():
			if i > 0 and p[i] >= "A" and p[i] <= "Z":
				result += " "
			result += p[i]
		result += " "
	return TranslationServer.translate(result.strip_edges())
