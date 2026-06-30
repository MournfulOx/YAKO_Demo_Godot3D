extends Node

var _played: Dictionary = {}

func has_played(map_id: String) -> bool:
	return _played.get(map_id, false)

func mark_played(map_id: String) -> void:
	_played[map_id] = true
