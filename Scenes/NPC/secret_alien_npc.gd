extends "res://Scenes/NPC/npc_base.gd"

func _ready() -> void:
	if not YellowDuckState.has_collected_all():
		visible = false
		collision_layer = 0
		collision_mask = 0
		set_process(false)
		set_physics_process(false)
		return
	super._ready()
