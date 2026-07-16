extends Area3D

@export var target_path: NodePath

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		var target: Node3D = get_node_or_null(target_path)
		if target != null:
			body.global_position = target.global_position
