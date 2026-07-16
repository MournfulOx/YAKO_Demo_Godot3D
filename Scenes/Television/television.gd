extends "res://Scenes/NPC/npc_base.gd"

signal ending_triggered

# Shown instead of dialogue_lines/repeat_lines if the player has found all
# YellowDuckState collectibles before reaching the TV.
@export var secret_dialogue_lines : Array[String] = [
	"are you here",
	"you found all of me.",
	"every little piece.",
	"we are always broadcasting.",
]
@export var secret_repeat_lines : Array[String] = ["we are always broadcasting."]

const GLOW_COLOR := Color(0.31, 0.765, 0.831)

# Grid offsets spread the 4 stock colour variants (which all import stacked
# at the same origin) into a wall of screens, à la Serial Experiments Lain.
const VARIANT_OFFSETS := {
	"TVBlack":  Vector3(0.0, 0.65, -0.6),
	"TVBox":    Vector3(0.0, 0.65, 0.6),
	"TVGrey":   Vector3(0.0, -0.65, -0.6),
	"TVYellow": Vector3(0.0, -0.65, 0.6),
}

# Approximate screen centre per variant (own pre-offset local space), used
# only to place the glow light — doesn't need to be pixel-accurate since it's
# just a light position, not something readability depends on.
const SCREEN_CENTER := {
	"TVBlack":  Vector3(0.26, -0.039, 0.354),
	"TVBox":    Vector3(0.42, 0.0, 0.647),
	"TVGrey":   Vector3(0.34, 0.0, 0.48),
	"TVYellow": Vector3(0.29, 0.0, 0.39),
}

func _ready() -> void:
	_spread_variants(self)
	if YellowDuckState.has_collected_all():
		dialogue_lines = secret_dialogue_lines
		repeat_lines   = secret_repeat_lines
	super._ready()
	_apply_screen_static(self)
	_add_screen_lights(self)
	ended.connect(func() -> void: ending_triggered.emit())

func _spread_variants(node: Node) -> void:
	for child: Node in node.get_children():
		var matched_key := ""
		for key: String in VARIANT_OFFSETS.keys():
			if child.name.begins_with(key):
				matched_key = key
				break
		if matched_key != "":
			if child is Node3D:
				(child as Node3D).position += VARIANT_OFFSETS[matched_key]
		else:
			_spread_variants(child)

func _apply_screen_static(node: Node) -> void:
	if node is MeshInstance3D and "Screen" in node.name:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			var shader := load("res://shaders/tv_screen_static.gdshader") as Shader
			for i: int in mi.mesh.get_surface_count():
				var smat := ShaderMaterial.new()
				smat.shader = shader
				mi.set_surface_override_material(i, smat)
	for child: Node in node.get_children():
		_apply_screen_static(child)

func _add_screen_lights(node: Node) -> void:
	for key: String in SCREEN_CENTER.keys():
		var wrapper := node.find_child(key, true, false)
		if wrapper == null:
			continue
		var light := OmniLight3D.new()
		light.light_color    = GLOW_COLOR
		light.light_energy   = 1.4
		light.omni_range     = 1.5
		light.shadow_enabled = false
		light.position       = SCREEN_CENTER[key]
		wrapper.add_child(light)
