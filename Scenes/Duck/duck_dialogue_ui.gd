extends CanvasLayer

const CHAR_INTERVAL  := 0.045
const HOLD_DURATION  := 1.8
const FADE_DURATION  := 0.5
const LINE_GAP       := 0.25
const BLIP_FREQ      := 400.0
const BLIP_DURATION  := 0.055
const BLIP_RATE      := 11025.0

var _label : Label
var _audio : AudioStreamPlayer

func _ready() -> void:
	layer = 4

	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_label.offset_top    = -52.0
	_label.offset_bottom = -14.0
	_label.offset_left   = 12.0
	_label.offset_right  = -12.0
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var ls := LabelSettings.new()
	ls.font_color    = Color.WHITE
	ls.font_size     = 6
	ls.outline_size  = 1
	ls.outline_color = Color.BLACK
	var pf := load("res://Scenes/Fonts/pixel.ttf") as FontFile
	if pf:
		ls.font = pf
	_label.label_settings = ls
	_label.modulate.a = 0.0
	add_child(_label)

	var gen := AudioStreamGenerator.new()
	gen.mix_rate      = BLIP_RATE
	gen.buffer_length = BLIP_DURATION + 0.02
	_audio = AudioStreamPlayer.new()
	_audio.stream    = gen
	_audio.volume_db = -8.0
	add_child(_audio)

func play_lines(lines: Array[String]) -> void:
	for i: int in lines.size():
		await _play_one(lines[i], i < lines.size() - 1)

func _play_one(text: String, add_gap: bool) -> void:
	_label.modulate.a = 1.0
	_label.text = ""

	for i: int in text.length():
		_label.text = text.substr(0, i + 1)
		if text[i] != " ":
			_play_blip()
		await get_tree().create_timer(CHAR_INTERVAL).timeout

	await get_tree().create_timer(HOLD_DURATION).timeout

	var tw := create_tween()
	tw.tween_property(_label, "modulate:a", 0.0, FADE_DURATION)
	await tw.finished

	if add_gap:
		await get_tree().create_timer(LINE_GAP).timeout

func _play_blip() -> void:
	_audio.stop()
	_audio.play()
	var pb := _audio.get_stream_playback() as AudioStreamGeneratorPlayback
	if pb == null:
		return
	var n := int(BLIP_RATE * BLIP_DURATION)
	for i: int in n:
		var env  := pow(1.0 - float(i) / n, 0.4)
		var wave := 1.0 if sin(TAU * BLIP_FREQ * float(i) / BLIP_RATE) >= 0.0 else -1.0
		pb.push_frame(Vector2.ONE * wave * env * 0.5)
