extends Node3D

const BOB_AMPLITUDE := 0.75
const BOB_DURATION := 1.2

func _ready() -> void:
	var base_y := position.y
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(self, "position:y", base_y + BOB_AMPLITUDE, BOB_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position:y", base_y - BOB_AMPLITUDE, BOB_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
