extends Node

var pending_spawn_id: String = ""

func set_pending_spawn(id: String) -> void:
	pending_spawn_id = id

func consume_pending_spawn() -> String:
	var id := pending_spawn_id
	pending_spawn_id = ""
	return id
