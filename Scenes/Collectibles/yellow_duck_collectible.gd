extends Area3D

signal collected

@export var duck_id: String = ""

func _ready() -> void:
	if duck_id == "" or YellowDuckState.has_collected(duck_id):
		queue_free()
		return
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		YellowDuckState.collect(duck_id)
		collected.emit()
		queue_free()
