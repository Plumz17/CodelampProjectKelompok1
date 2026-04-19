extends CharacterBody2D
class_name EnemyBase

@export var max_fear_bar: int # Enemy's HP
@export var speed: float
@export var terror_energy: int # Enemy Drop
@export var waypoints_node: Node2D # A Node with Waypoints as it's child

# Some runtime variables
var waypoints: Array[Vector2] = []
var current_fear_bar: int 
var current_waypoint_index: int = 0

func _ready() -> void:
	#Set Fear Bar / Enemy HP
	current_fear_bar = max_fear_bar
	#Get location of all waypoints
	for waypoint: Node2D in waypoints_node.get_children():
		waypoints.append(waypoint.global_position)

func _physics_process(_delta: float) -> void:
	#Print Error if there's no waypoints or if it's empty
	if waypoints.is_empty():
		printerr("Waypoints Empty")
		return
	
	#Call the reach_core() function if enemy reach end
	if current_waypoint_index >= waypoints.size():
		reach_core()
		return
	
	#Go to next waypoint
	var next_waypoint: Vector2 = waypoints[current_waypoint_index]
	var direction: Vector2 = (next_waypoint - global_position).normalized()
	velocity = direction * speed * 20 #the 20 here is an arbitrary value, change speed manually later
	move_and_slide()
	
	#Update waypoint index if enemy is near the target waypoint
	if global_position.distance_to(next_waypoint) < 6.7:
		current_waypoint_index += 1

#Function when reaching core, TODO: add attacking core logic here
func reach_core():
	print("Core Reached!")
	return
