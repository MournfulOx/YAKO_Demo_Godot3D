extends Area3D

@export_file("*.tscn") var target_scene: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not (body is CharacterBody3D) or target_scene.is_empty() or BackroomState.has_entered():
		return
	BackroomState.mark_entered()
	SceneManager.change_scene(target_scene)
