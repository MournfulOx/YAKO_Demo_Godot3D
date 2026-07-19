extends Node

var _entered : bool = false

func has_entered() -> bool:
	return _entered

func mark_entered() -> void:
	_entered = true
