extends Area3D

@export var duck_id : String = ""
@export var lines   : Array[String] = [
	"a little piece of you.",
	"some birds just draw themselves smaller than they are.",
]

const VANISH_DURATION := 0.45
const VANISH_RISE      := 0.6

var _light : OmniLight3D

func _ready() -> void:
	if duck_id == "" or YellowDuckState.has_collected(duck_id):
		queue_free()
		return
	_apply_psx_shader(self)
	_add_light()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody3D:
		return
	body_entered.disconnect(_on_body_entered)
	_collect.call_deferred()

func _collect() -> void:
	var ui : CanvasLayer = load("res://Scenes/Duck/duck_dialogue_ui.gd").new()
	add_child(ui)
	await ui.play_lines(lines)
	YellowDuckState.collect(duck_id)
	await _vanish()
	queue_free()

func _vanish() -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector3.ZERO, VANISH_DURATION) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "position:y", position.y + VANISH_RISE, VANISH_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(_light, "light_energy", _light.light_energy * 2.5, VANISH_DURATION * 0.4) \
		.set_ease(Tween.EASE_OUT)
	await tw.finished

func _add_light() -> void:
	_light = OmniLight3D.new()
	_light.light_color    = Color(1.0, 0.88, 0.55)
	_light.light_energy   = 2.0
	_light.omni_range     = 2.0
	_light.shadow_enabled = false
	_light.position       = Vector3(0.0, 0.3, 0.0)
	add_child(_light)

func _apply_psx_shader(node: Node) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh == null:
			return
		var shader := load("res://shaders/psx_lit.gdshader") as Shader
		for i: int in mi.mesh.get_surface_count():
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
			mi.set_surface_override_material(i, smat)
	for child: Node in node.get_children():
		_apply_psx_shader(child)
