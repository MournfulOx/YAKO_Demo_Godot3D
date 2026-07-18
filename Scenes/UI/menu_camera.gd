extends Camera3D

@export var look_at_path : NodePath

func _ready() -> void:
	current = true
	var target: Node3D = get_node_or_null(look_at_path)
	if target != null:
		look_at(target.global_position, Vector3.UP)
