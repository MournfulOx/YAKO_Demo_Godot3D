extends CharacterBody3D

enum State { HIDDEN, CARTON_CLOSED, CARTON_OPENING, CARTON_OPEN, SMOKING }

@onready var head        := $Head
@onready var camera      : Camera3D       = $Head/Camera3D
@onready var cigarette                    = $Head/Camera3D/ItemAnchor/CigAnchor
@onready var carton                       = $Head/Camera3D/ItemAnchor/CigCartonAnchor
@onready var carton_anim : AnimationPlayer = $Head/Camera3D/ItemAnchor/CigCartonAnchor/cigs_carton/AnimationPlayer

@export var sensitivity   : float = 0.002
@export var speed         : float = 6.0
@export var speed_smoking : float = 3.0

const STEP_INTERVAL        := 0.42
const STEP_INTERVAL_SLOW   := 0.60
const STEP_BLIP_RATE       := 11025.0
const STEP_BLIP_DURATION   := 0.07

var state := State.HIDDEN

var _carton_rest : Vector3
var _cig_rest    : Vector3
const _APPEAR_OFFSET := Vector3(0.0, -0.06, 0.0)
const _APPEAR_TIME   := 0.25
var _carton_tween : Tween
var _cig_tween    : Tween

const NPC_INTERACT_RANGE := 1.5

const BOB_SPEED := 1.3
const BOB_AMP_Y := 0.008
const BOB_AMP_X := 0.004

var _aimed_npc   : Node3D = null
var _current_npc : Node3D = null
var _dialogue_ui : CanvasLayer
var _pause_menu  : CanvasLayer

var _step_audio : AudioStreamPlayer
var _step_timer : float = 0.0
var _bob_time   : float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_carton_rest = carton.position
	_cig_rest    = cigarette.position
	carton.visible    = false
	cigarette.visible = false
	carton_anim.animation_finished.connect(_on_carton_anim_finished)
	cigarette.burned_out.connect(_on_cigarette_burned_out)

	_dialogue_ui = load("res://Scenes/UI/dialogue_ui.gd").new()
	add_child(_dialogue_ui)

	_pause_menu = load("res://Scenes/UI/pause_menu_ui.gd").new()
	add_child(_pause_menu)

	add_child(load("res://Scenes/Collectibles/duck_pickup_notification_ui.gd").new())

	var gen := AudioStreamGenerator.new()
	gen.mix_rate      = STEP_BLIP_RATE
	gen.buffer_length = STEP_BLIP_DURATION + 0.02
	_step_audio = AudioStreamPlayer.new()
	_step_audio.stream    = gen
	_step_audio.volume_db = -18.0
	add_child(_step_audio)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		head.rotate_x(-event.relative.y * sensitivity)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

	if event is InputEventKey and event.is_action_pressed("Smoke") and not event.is_echo():
		if _current_npc == null:
			if state == State.HIDDEN:
				_enter_carton_closed()
			else:
				_enter_hidden()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _current_npc != null:
				_npc_advance()
				return
			if _aimed_npc != null:
				_npc_start(_aimed_npc)
				return
			match state:
				State.CARTON_CLOSED:
					_enter_carton_opening()
				State.CARTON_OPEN:
					_enter_smoking()
				State.SMOKING:
					cigarette.start_smoking()
		else:
			if state == State.SMOKING:
				cigarette.stop_smoking()

func _process(delta: float) -> void:
	if _current_npc == null:
		_update_npc_aim()
	_update_head_bob(delta)

func _update_head_bob(delta: float) -> void:
	var spd: float = velocity.length()
	if spd > 0.5:
		_bob_time += spd * delta * BOB_SPEED
		var target := Vector3(
			sin(_bob_time * 0.5) * BOB_AMP_X,
			sin(_bob_time)       * BOB_AMP_Y,
			0.0)
		camera.position = camera.position.lerp(target, 12.0 * delta)
	else:
		camera.position = camera.position.lerp(Vector3.ZERO, 8.0 * delta)

func _update_npc_aim() -> void:
	var space  := get_world_3d().direct_space_state
	var origin := camera.global_position
	var target := origin + -camera.global_transform.basis.z * 2.0
	var query  := PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [self]
	var hit := space.intersect_ray(query)

	var found: Node3D = null
	if not hit.is_empty():
		var dist := global_position.distance_to(hit["position"])
		if dist <= NPC_INTERACT_RANGE:
			var node: Node = hit.get("collider", null)
			while node != null:
				if node.is_in_group("npc"):
					found = node as Node3D
					break
				node = node.get_parent()

	if found != _aimed_npc:
		if _aimed_npc != null and _aimed_npc.has_method("set_outline"):
			_aimed_npc.set_outline(false)
		_aimed_npc = found
		if _aimed_npc != null and _aimed_npc.has_method("set_outline"):
			_aimed_npc.set_outline(true)

func _npc_start(npc: Node3D) -> void:
	if state != State.HIDDEN:
		_enter_hidden()
	_current_npc = npc
	if _aimed_npc == npc:
		if npc.has_method("set_outline"):
			npc.set_outline(false)
		_aimed_npc = null
	npc.line_shown.connect(_on_npc_line_shown)
	npc.ended.connect(_on_npc_ended, CONNECT_ONE_SHOT)
	npc.start()

func _npc_advance() -> void:
	if _dialogue_ui.is_typing():
		_dialogue_ui.skip_typing()
		return
	if _current_npc != null and _current_npc.has_method("advance"):
		_current_npc.advance()

func _on_npc_line_shown(text: String) -> void:
	var pitch: float = 1.0
	if _current_npc != null and "voice_pitch" in _current_npc:
		pitch = _current_npc.voice_pitch
	_dialogue_ui.show_line(text, pitch)

func _on_npc_ended() -> void:
	_dialogue_ui.hide_ui()
	if _current_npc != null:
		if _current_npc.line_shown.is_connected(_on_npc_line_shown):
			_current_npc.line_shown.disconnect(_on_npc_line_shown)
		_current_npc = null

# ── Cigarette state machine ────────────────────────────────────────────────

func _appear(node: Node3D, rest: Vector3) -> Tween:
	var t := create_tween()
	node.position = rest + _APPEAR_OFFSET
	node.visible  = true
	t.tween_property(node, "position", rest, _APPEAR_TIME) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	return t

func _disappear(node: Node3D, rest: Vector3) -> Tween:
	var t := create_tween()
	t.tween_property(node, "position", rest + _APPEAR_OFFSET, _APPEAR_TIME) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	t.tween_callback(func():
		node.visible  = false
		node.position = rest
	)
	return t

func _kill_tweens() -> void:
	if _carton_tween and _carton_tween.is_running():
		_carton_tween.kill()
	if _cig_tween and _cig_tween.is_running():
		_cig_tween.kill()

func _enter_hidden() -> void:
	var prev := state
	state = State.HIDDEN
	_kill_tweens()
	if prev == State.SMOKING:
		cigarette.stop_smoking()
		_cig_tween = _disappear(cigarette, _cig_rest)
	else:
		_reset_carton_anim()
		_carton_tween = _disappear(carton, _carton_rest)

func _enter_carton_closed() -> void:
	state = State.CARTON_CLOSED
	_kill_tweens()
	_carton_tween = _appear(carton, _carton_rest)

func _enter_carton_opening() -> void:
	state = State.CARTON_OPENING
	carton_anim.play("CartonTopOpen")

func _enter_carton_open() -> void:
	state = State.CARTON_OPEN

func _enter_smoking() -> void:
	state = State.SMOKING
	_kill_tweens()
	_carton_tween = _disappear(carton, _carton_rest)
	cigarette.reset_cigarette()
	_cig_tween = _appear(cigarette, _cig_rest)

func _reset_carton_anim() -> void:
	carton_anim.play("CartonTopOpen")
	carton_anim.seek(0.0, true)
	carton_anim.stop()

func _on_carton_anim_finished(_anim_name: StringName) -> void:
	if state == State.CARTON_OPENING:
		_enter_carton_open()

func _on_cigarette_burned_out() -> void:
	_kill_tweens()
	_cig_tween = _disappear(cigarette, _cig_rest)
	_reset_carton_anim()
	state = State.CARTON_CLOSED
	var t := create_tween()
	t.tween_interval(_APPEAR_TIME)
	t.tween_callback(func():
		if state == State.CARTON_CLOSED:
			_carton_tween = _appear(carton, _carton_rest)
	)

func _physics_process(delta: float) -> void:
	var input     := Input.get_vector("Left", "Right", "Fowared", "Back")
	var direction := (transform.basis.x * input.x + transform.basis.z * input.y).normalized()
	var cur_speed := speed_smoking if cigarette.is_smoking else speed
	velocity = direction * cur_speed
	move_and_slide()

	if direction.length_squared() > 0.01:
		_step_timer -= delta
		if _step_timer <= 0.0:
			var spd: float = velocity.length()
			_step_timer = STEP_INTERVAL_SLOW if cigarette.is_smoking else STEP_INTERVAL
			_play_footstep(spd / speed)
	else:
		_step_timer = 0.0

func _play_footstep(speed_ratio: float) -> void:
	_step_audio.stop()
	_step_audio.play()
	var pb := _step_audio.get_stream_playback() as AudioStreamGeneratorPlayback
	if pb == null:
		return
	var n    := int(STEP_BLIP_RATE * STEP_BLIP_DURATION)
	var freq: float = lerpf(55.0, 95.0, clamp(speed_ratio, 0.0, 1.0))
	for i: int in n:
		var t     := float(i) / STEP_BLIP_RATE
		var env   := pow(1.0 - float(i) / n, 0.55)
		var tone  := sin(TAU * freq * t) * 0.25
		var noise := randf_range(-1.0, 1.0) * 0.75
		pb.push_frame(Vector2.ONE * (tone + noise) * env * 0.45)
