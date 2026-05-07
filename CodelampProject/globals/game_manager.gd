extends Node

@export var levels: Array[PackedScene]

var current_level_index: int = 0

func set_current_level_index(index: int) -> void:
	current_level_index = index

func get_level(level_index: int) -> PackedScene:
	if levels.is_empty():
		printerr("LevelManager: No levels assigned!")
		return null
	if level_index < 0 or level_index >= levels.size():
		printerr("LevelManager: Level index %d out of range!" % level_index)
		return null
	return levels[level_index]

func get_current_level() -> PackedScene:
	return get_level(current_level_index)

func get_next_level() -> PackedScene:
	if current_level_index + 1 >= levels.size():
		print("LevelManager: Already at last level.")
		return null
	current_level_index += 1
	return get_current_level()

func has_next_level() -> bool:
	return current_level_index + 1 < levels.size()

func is_last_level() -> bool:
	return current_level_index >= levels.size() - 1

func reset() -> void:
	current_level_index = 0
