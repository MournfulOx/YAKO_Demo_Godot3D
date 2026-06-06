extends Area3D

@export_file("*.tscn") var target_scene: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D and not target_scene.is_empty():
		get_tree().change_scene_to_file.call_deferred(target_scene)
