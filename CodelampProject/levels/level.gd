extends Node2D
class_name Level

@export var initial_terror_energy: int
@export var wave_data: Array[WaveData]

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var waypoints_node: Node2D = $Waypoints
