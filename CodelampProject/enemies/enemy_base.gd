extends CharacterBody2D
class_name EnemyBase

@export var max_fear_bar: int # Maximum health/fear capacity
@export var speed: float # Movement speed modifier
@export var terror_energy: int # Resource dropped upon defeat
@export var waypoints_node: Node2D # Reference to the Waypoints parent node
@export var core_damage: int = 10 # Damage dealt to the player's core upon reaching it

# Runtime state variables
var waypoints: Array[Vector2] = []
var current_fear_bar: int 
var current_waypoint_index: int = 0

func _ready() -> void:
	# Initialize base stats
	current_fear_bar = max_fear_bar
	
	# Populate waypoints array with global coordinates
	if waypoints_node:
		for waypoint: Node2D in waypoints_node.get_children():
			waypoints.append(waypoint.global_position)

func _physics_process(_delta: float) -> void:
	# Guard clause: Ensure pathing data exists
	if waypoints.is_empty():
		printerr("Error: Waypoints array is empty.")
		return
	
	# Check if the entity has reached the final destination
	if current_waypoint_index >= waypoints.size():
		reach_core()
		return
	
	# Calculate trajectory and move towards the active waypoint
	var next_waypoint: Vector2 = waypoints[current_waypoint_index]
	var direction: Vector2 = (next_waypoint - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Proceed to the next waypoint upon reaching the distance threshold
	if global_position.distance_to(next_waypoint) < 6.7:
		current_waypoint_index += 1

# Handles logic when the entity reaches the player's core
func reach_core() -> void:
	# Apply final velocity to ensure collision overlap with Core's Area2D
	move_and_slide()
	print("Core Reached!")
	return
