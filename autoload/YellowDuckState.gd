extends Node

# 1 per map across Map_01-04, plus 1 more hidden in the Map_03 Backrooms egg.
const TOTAL_DUCKS := 5

signal duck_collected(count: int, total: int)

var _collected: Dictionary = {}

func collect(duck_id: String) -> void:
	_collected[duck_id] = true
	duck_collected.emit(collected_count(), TOTAL_DUCKS)

func has_collected(duck_id: String) -> bool:
	return _collected.get(duck_id, false)

func collected_count() -> int:
	return _collected.size()

func has_collected_all() -> bool:
	return collected_count() >= TOTAL_DUCKS
