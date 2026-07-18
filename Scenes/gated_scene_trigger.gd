extends Area3D

@export_file("*.tscn") var target_scene: String = ""
@export var required_npc_path: NodePath

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not (body is CharacterBody3D) or target_scene.is_empty():
		return
	var npc: Node = get_node_or_null(required_npc_path)
	if npc != null and npc.has_method("is_complete") and not npc.is_complete():
		return
	SceneManager.change_scene(target_scene)
