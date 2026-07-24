extends Node

const TRACKS := {
	"res://Scenes/UI/MainMenu.tscn": "res://Scenes/BGM/MainMenu.mp3",
	"res://Scenes/Maps/Map_01_ConvenienceStore.tscn": "res://Scenes/BGM/Map01.mp3",
	"res://Scenes/Maps/Map_02_Crossroads.tscn": "res://Scenes/BGM/Map02.mp3",
	"res://Scenes/Maps/Map_03_UnderTheOverPass.tscn": "res://Scenes/BGM/Map03.mp3",
	"res://Scenes/Maps/Map_04_ArcadeAlley.tscn": "res://Scenes/BGM/Map04.mp3",
	"res://Scenes/Maps/Map_05_SchoolRooftop.tscn": "res://Scenes/BGM/Map05.mp3",
	"res://Scenes/Maps/Backroom.tscn": "res://Scenes/BGM/Backroom.mp3",
}

const BUS_NAME := "Music"
const TARGET_VOLUME_DB := -14.0
const SILENT_VOLUME_DB := -80.0
const FADE_TIME := 0.4

var _player: AudioStreamPlayer
var _current_scene_path := ""
var _fade_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_bus()

	_player = AudioStreamPlayer.new()
	_player.bus = BUS_NAME
	add_child(_player)

	call_deferred("_play_initial_scene")

func _setup_bus() -> void:
	if AudioServer.get_bus_index(BUS_NAME) != -1:
		return
	AudioServer.add_bus()
	var idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, BUS_NAME)

	# Muffled, low-fidelity texture — matches the PSX/tape-hiss brief the
	# tracks were generated to, not a clean modern mix.
	var lowpass := AudioEffectLowPassFilter.new()
	lowpass.cutoff_hz = 3200.0
	AudioServer.add_bus_effect(idx, lowpass)

	var lofi := AudioEffectDistortion.new()
	lofi.mode = AudioEffectDistortion.MODE_LOFI
	lofi.pre_gain = -6.0
	AudioServer.add_bus_effect(idx, lofi)

func _play_initial_scene() -> void:
	var scene := get_tree().current_scene
	if scene and not scene.scene_file_path.is_empty():
		play_for_scene(scene.scene_file_path)

func play_for_scene(scene_path: String) -> void:
	if scene_path == _current_scene_path:
		return
	_current_scene_path = scene_path

	var track_path: String = TRACKS.get(scene_path, "")
	if _fade_tween:
		_fade_tween.kill()

	if track_path.is_empty():
		_fade_tween = create_tween()
		_fade_tween.tween_property(_player, "volume_db", SILENT_VOLUME_DB, FADE_TIME)
		await _fade_tween.finished
		_player.stop()
		return

	if _player.playing:
		_fade_tween = create_tween()
		_fade_tween.tween_property(_player, "volume_db", SILENT_VOLUME_DB, FADE_TIME)
		await _fade_tween.finished

	var stream: AudioStream = load(track_path)
	if stream is AudioStreamMP3:
		stream.loop = true
	_player.stream = stream
	_player.volume_db = SILENT_VOLUME_DB
	_player.play()

	_fade_tween = create_tween()
	_fade_tween.tween_property(_player, "volume_db", TARGET_VOLUME_DB, FADE_TIME)
