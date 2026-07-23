extends Area3D

@export_file("*.tscn") var target_scene: String = ""
@export var required_npc_path: NodePath
@export var spawn_id: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not (body is CharacterBody3D) or target_scene.is_empty():
		return
	if not required_npc_path.is_empty():
		var npc: Node = get_node_or_null(required_npc_path)
		if npc == null or not npc.has_method("is_complete") or not npc.is_complete():
			return
	if not spawn_id.is_empty():
		TravelState.set_pending_spawn(spawn_id)
	SceneManager.change_scene(target_scene)
