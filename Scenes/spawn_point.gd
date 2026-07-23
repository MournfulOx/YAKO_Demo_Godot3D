extends Marker3D

@export var spawn_id: String = ""

func _ready() -> void:
	if not spawn_id.is_empty():
		add_to_group("spawn_point")
