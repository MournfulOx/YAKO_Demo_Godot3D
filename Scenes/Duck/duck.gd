extends Node3D

@export var map_id: String = ""
@export var sheep_npc: Node3D = null

var _ui: CanvasLayer

func _ready() -> void:
	_apply_psx_shader(self)
	_add_light()
	_ui = load("res://Scenes/Duck/duck_dialogue_ui.gd").new()
	add_child(_ui)
	if sheep_npc != null:
		sheep_npc.ended.connect(_on_sheep_ended, CONNECT_ONE_SHOT)

func trigger() -> void:
	if DuckState.has_played(map_id):
		return
	DuckState.mark_played(map_id)
	_play_lines()

func _on_sheep_ended() -> void:
	if DuckState.has_played(map_id):
		return
	DuckState.mark_played(map_id)
	_play_lines()

func _play_lines() -> void:
	await _ui.play_lines(_lines_for(map_id))
	queue_free()

func _add_light() -> void:
	var light := OmniLight3D.new()
	light.light_color    = Color(1.0, 0.88, 0.55)
	light.light_energy   = 2.8
	light.omni_range     = 2.5
	light.shadow_enabled = false
	light.position       = Vector3(0.0, 0.3, 0.0)
	add_child(light)

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

static func _lines_for(id: String) -> Array[String]:
	match id:
		"Map_01_ConvenienceStore":
			return ["Oh. There you are."]
		"Map_02_Crossroads":
			return ["Your shoelace is undone.", "Just kidding."]
		"Map_03_UnderTheOverPass":
			return ["Five centimeters per second.", "That's how fast you walk."]
		"Map_04_ArcadeAlley":
			return ["Video games have saved a lot of people.", "Probably.", "The cat looks happy."]
		"Map_05_Rooftop_final":
			return ["The boring daytime is starting again."]
		_:
			return []
