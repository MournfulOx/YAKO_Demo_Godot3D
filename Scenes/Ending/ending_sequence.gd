extends Node

@export var television_path: NodePath

var television: Node3D

func _ready() -> void:
	television = get_node_or_null(television_path)
	if television != null:
		television.ending_triggered.connect(_on_ending_triggered)

func _on_ending_triggered() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	var ui: CanvasLayer = load("res://Scenes/Ending/ending_title_ui.gd").new()
	get_tree().root.add_child(ui)
	ui.play()
