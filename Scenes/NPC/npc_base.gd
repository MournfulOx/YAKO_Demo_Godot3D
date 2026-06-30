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

func _ready() -> void:
	add_to_group("npc")
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

func set_outline(on: bool) -> void:
	_outline_recursive(self, on)

func _current_lines() -> Array[String]:
	return repeat_lines if _complete else dialogue_lines

func _finish() -> void:
	_active   = false
	_complete = true
	ended.emit()

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
