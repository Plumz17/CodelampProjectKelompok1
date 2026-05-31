extends Node2D
class_name Level

var _level_route_config: Dictionary = {
	"Level2": [
		PackedInt32Array([1, 2, 3, 4, 10]),
		PackedInt32Array([1, 2, 5, 6, 7, 8, 9, 10])
	],
	"Level3": [
		PackedInt32Array([1, 2, 3, 4, 10]),
		PackedInt32Array([1, 2, 5, 6, 7, 8, 9, 10])
	],
	"Level4": [
		PackedInt32Array([1, 2, 3, 4, 10]),
		PackedInt32Array([1, 2, 5, 6, 7, 4, 10]),
		PackedInt32Array([1, 2, 5, 6, 8, 9, 10])
	]
}

@export var initial_terror_energy: int
@export var wave_data: Array[WaveData]

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var waypoints_node: Node2D = $Waypoints

var _waypoint_positions_by_number: Dictionary = {}

func _ready() -> void:
	_collect_waypoint_positions()

func _collect_waypoint_positions() -> void:
	_waypoint_positions_by_number.clear()
	if not waypoints_node:
		return
	var marker_number: int = 1
	for child in waypoints_node.get_children():
		if child is Marker2D:
			var marker := child as Marker2D
			_waypoint_positions_by_number[marker_number] = marker.global_position
			marker_number += 1

func _get_sorted_marker_numbers() -> Array[int]:
	var numbers: Array[int] = []
	for key in _waypoint_positions_by_number.keys():
		numbers.append(int(key))
	numbers.sort()
	return numbers

func get_default_waypoint_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for marker_number in _get_sorted_marker_numbers():
		positions.append(_waypoint_positions_by_number[marker_number])
	return positions

func get_waypoint_positions_for_spawn(spawn_order: int) -> Array[Vector2]:
	if not _level_route_config.has(name):
		return get_default_waypoint_positions()
	var routes: Array = _level_route_config[name]
	if routes.is_empty():
		return get_default_waypoint_positions()
	var route_index: int = posmod(spawn_order, routes.size())
	var route_markers: PackedInt32Array = routes[route_index]
	var positions: Array[Vector2] = []
	for marker_number in route_markers:
		if _waypoint_positions_by_number.has(marker_number):
			positions.append(_waypoint_positions_by_number[marker_number])
	if positions.is_empty():
		return get_default_waypoint_positions()
	return positions
