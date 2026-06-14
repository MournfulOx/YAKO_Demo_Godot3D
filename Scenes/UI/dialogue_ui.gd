extends CanvasLayer

var _label  : Label
var _prompt : Label

func _ready() -> void:
	layer = 5

	_label = Label.new()
	_label.name = "NPCText"
	_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_label.offset_top    = -52.0
	_label.offset_bottom = -14.0
	_label.offset_left   = 12.0
	_label.offset_right  = -12.0
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var ls := LabelSettings.new()
	ls.font_color    = Color.WHITE
	ls.font_size     = 8
	ls.outline_size  = 1
	ls.outline_color = Color.BLACK
	_label.label_settings = ls
	_label.visible = false
	add_child(_label)

	_prompt = Label.new()
	_prompt.name = "AdvancePrompt"
	_prompt.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_prompt.offset_top    = -14.0
	_prompt.offset_bottom = -4.0
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var ps := LabelSettings.new()
	ps.font_color    = Color.WHITE
	ps.font_size     = 6
	ps.outline_size  = 1
	ps.outline_color = Color.BLACK
	_prompt.label_settings = ps
	_prompt.text    = "▼"
	_prompt.visible = false
	add_child(_prompt)

func show_line(text: String) -> void:
	_label.text     = text
	_label.visible  = true
	_prompt.visible = true

func hide_ui() -> void:
	_label.visible  = false
	_prompt.visible = false
