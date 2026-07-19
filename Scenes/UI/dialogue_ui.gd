extends CanvasLayer

const CHAR_INTERVAL := 0.045
const BLIP_FREQ     := 520.0
const BLIP_DURATION := 0.055
const BLIP_RATE     := 11025.0

var _label      : Label
var _prompt     : Label
var _audio      : AudioStreamPlayer
var _type_timer : Timer
var _label_settings : LabelSettings

var _full_text  : String = ""
var _char_idx   : int    = 0
var _typing     : bool   = false
var _base_pitch : float  = 1.0

func _ready() -> void:
	layer = 5

	_label = Label.new()
	_label.name = "NPCText"
	_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_label.offset_top    = -80.0
	_label.offset_bottom = -14.0
	_label.offset_left   = 12.0
	_label.offset_right  = -12.0
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label_settings = LabelSettings.new()
	_label_settings.font_color    = Color.WHITE
	_label_settings.font_size     = 6
	_label_settings.outline_size  = 1
	_label_settings.outline_color = Color.BLACK
	_label.label_settings = _label_settings
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

	var gen := AudioStreamGenerator.new()
	gen.mix_rate     = BLIP_RATE
	gen.buffer_length = BLIP_DURATION + 0.02
	_audio = AudioStreamPlayer.new()
	_audio.stream    = gen
	_audio.volume_db = -8.0
	add_child(_audio)

	_type_timer = Timer.new()
	_type_timer.wait_time = CHAR_INTERVAL
	_type_timer.one_shot  = false
	_type_timer.timeout.connect(_on_type_tick)
	add_child(_type_timer)

func show_line(text: String, pitch: float = 1.0) -> void:
	_type_timer.stop()
	_label_settings.font      = SettingsState.get_active_font()
	_label_settings.font_size = SettingsState.get_display_font_size(9, 16)
	_full_text  = tr(text)
	_char_idx   = 0
	_base_pitch = pitch
	_typing     = true
	_label.text     = ""
	_label.visible  = true
	_prompt.visible = false
	_type_timer.start()

func _on_type_tick() -> void:
	if _char_idx >= _full_text.length():
		_finish_typing()
		return
	_char_idx += 1
	_label.text = _full_text.substr(0, _char_idx)
	if _full_text[_char_idx - 1] != " ":
		_play_blip(_base_pitch + randf_range(-0.06, 0.06))

func _play_blip(pitch: float) -> void:
	_audio.stop()
	_audio.play()
	var pb := _audio.get_stream_playback() as AudioStreamGeneratorPlayback
	if pb == null:
		return
	var n    := int(BLIP_RATE * BLIP_DURATION)
	var freq := BLIP_FREQ * pitch
	for i: int in n:
		var env  := pow(1.0 - float(i) / n, 0.4)
		var wave := 1.0 if sin(TAU * freq * float(i) / BLIP_RATE) >= 0.0 else -1.0
		pb.push_frame(Vector2.ONE * wave * env * 0.5)

func _finish_typing() -> void:
	_type_timer.stop()
	_label.text     = _full_text
	_typing         = false
	_prompt.visible = true

func is_typing() -> bool:
	return _typing

func skip_typing() -> void:
	if _typing:
		_finish_typing()

func hide_ui() -> void:
	_type_timer.stop()
	_typing         = false
	_label.visible  = false
	_prompt.visible = false
