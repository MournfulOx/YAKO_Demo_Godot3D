extends CharacterBody3D

@onready var head := $Head

var sensitivity := 0.002
const SPEED := 5.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		head.rotate_x(-event.relative.y * sensitivity)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
	
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("Left", "Right", "Fowared", "Back")
	var direction := (transform.basis.x * input.x + transform.basis.z * input.y).normalized()
	velocity = direction * SPEED
	move_and_slide()
