extends Area3D

@export var duck: Node3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body is CharacterBody3D:
		return
	body_entered.disconnect(_on_body_entered)
	_fire.call_deferred()

func _fire() -> void:
	if duck != null:
		duck.trigger()
