extends Area3D

@export_file("*.tscn") var target_scene: String = ""
@export var spawn_id: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D and not target_scene.is_empty():
		if not spawn_id.is_empty():
			TravelState.set_pending_spawn(spawn_id)
		SceneManager.change_scene(target_scene)
