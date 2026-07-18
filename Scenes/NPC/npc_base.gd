extends StaticBody3D

@export var dialogue_lines : Array[String] = []
@export var repeat_lines   : Array[String] = []
@export var wobble_amount  : float         = 0.005
@export var voice_pitch    : float         = 1.0

signal line_shown(text: String)
signal ended

var _complete : bool = false
var _line_idx : int  = 0
var _active   : bool = false

var _outline_mat : ShaderMaterial

@export var light_energy : float = 1.2
@export var light_color  : Color = Color(0.91, 0.77, 0.28)  # Convenience Yellow

@export var face_player_on_interact : bool = true
# Correction for this model's own "front" direction — the face-toward-player
# math always points the root's -Z at the player, but not every downloaded
# model was authored facing -Z. Defaults to 180 because that's what most of
# this project's downloaded models turned out to need (confirmed by testing
# across the roster) — NPCs whose model already faces -Z natively (so far,
# only NPC_TRex) need an explicit override back to 0 in their own .tscn.
# If an NPC still turns to face sideways/backwards, try 90 or -90 instead.
# Doesn't affect the idle/resting pose at all, only where it turns to while
# talking.
@export var face_offset_deg : float = 180.0

const FACE_TURN_DURATION := 0.35

var _original_rotation_y : float = 0.0
var _face_tween          : Tween

func _ready() -> void:
	add_to_group("npc")
	_original_rotation_y = rotation.y
	_outline_mat = ShaderMaterial.new()
	_outline_mat.shader = load("res://shaders/npc_outline.gdshader")
	_apply_npc_shader(self)
	_add_npc_light()

func _add_npc_light() -> void:
	var light := OmniLight3D.new()
	light.light_color   = light_color
	light.light_energy  = light_energy
	light.omni_range    = 3.0
	light.shadow_enabled = false
	light.position      = Vector3(0.0, 1.0, 0.0)
	add_child(light)

func start() -> void:
	_active   = true
	_line_idx = 0
	if face_player_on_interact:
		_face_player()
	var lines := _current_lines()
	if lines.is_empty():
		_finish()
		return
	line_shown.emit(lines[0])

func advance() -> void:
	if not _active:
		return
	var lines := _current_lines()
	_line_idx += 1
	if _line_idx >= lines.size():
		_finish()
	else:
		line_shown.emit(lines[_line_idx])

func is_active() -> bool:
	return _active

func is_complete() -> bool:
	return _complete

func set_outline(on: bool) -> void:
	_outline_recursive(self, on)

func _current_lines() -> Array[String]:
	return repeat_lines if _complete else dialogue_lines

func _finish() -> void:
	_active   = false
	_complete = true
	if face_player_on_interact:
		_turn_to(_original_rotation_y)
	ended.emit()

# ── Face-player turn (Tween, shortest-path, reverts on _finish) ───────────

func _face_player() -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	_turn_to(_yaw_facing(cam.global_position))

func _yaw_facing(target_pos: Vector3) -> float:
	var flat_target := Vector3(target_pos.x, global_position.y, target_pos.z)
	if global_position.distance_to(flat_target) < 0.01:
		return rotation.y
	# Borrow Node3D's own (known-correct) look_at() to get the target angle,
	# rather than re-deriving it by hand — snap-look, read the result, revert.
	var saved_rotation := rotation
	look_at(flat_target, Vector3.UP)
	var result_y := rotation.y
	rotation = saved_rotation
	return result_y + deg_to_rad(face_offset_deg)

func _turn_to(target_y: float) -> void:
	if _face_tween != null and _face_tween.is_valid():
		_face_tween.kill()
	var current_y := rotation.y
	var delta_y := wrapf(target_y - current_y, -PI, PI)
	_face_tween = create_tween()
	_face_tween.tween_property(self, "rotation:y", current_y + delta_y, FACE_TURN_DURATION)

# ── NPC shader (PSX lit + per-vertex wobble) ──────────────────────────────

func _apply_npc_shader(node: Node) -> void:
	if node is MeshInstance3D:
		var mi    := node as MeshInstance3D
		var shader := load("res://shaders/psx_lit_npc.gdshader") as Shader
		if mi.mesh == null:
			return
		for i in mi.mesh.get_surface_count():
			var orig := mi.get_active_material(i)
			var smat := ShaderMaterial.new()
			smat.shader = shader
			if orig is BaseMaterial3D:
				var bm := orig as BaseMaterial3D
				if bm.albedo_texture != null:
					smat.set_shader_parameter("albedoTex", bm.albedo_texture)
				smat.set_shader_parameter("modulate_color", Vector4(
					bm.albedo_color.r, bm.albedo_color.g,
					bm.albedo_color.b, bm.albedo_color.a))
			smat.set_shader_parameter("wobble_amount", wobble_amount)
			mi.set_surface_override_material(i, smat)
	for child in node.get_children():
		_apply_npc_shader(child)

# ── Outline (white next_pass) ──────────────────────────────────────────────

func _outline_recursive(node: Node, on: bool) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			for i in mi.mesh.get_surface_count():
				if on:
					var ov := mi.get_surface_override_material(i)
					if ov == null:
						var base := mi.get_active_material(i)
						ov = base.duplicate() if base != null else StandardMaterial3D.new()
						mi.set_surface_override_material(i, ov)
					if ov.next_pass == null:
						ov.next_pass = _outline_mat
				else:
					var ov := mi.get_surface_override_material(i)
					if ov != null:
						ov.next_pass = null
	for child in node.get_children():
		_outline_recursive(child, on)
