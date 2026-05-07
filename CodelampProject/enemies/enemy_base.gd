extends CharacterBody2D
class_name EnemyBase

signal defeated(terror_energy_amount: int)

@export var max_fear_bar: int # Maximum health/fear capacity
@export var speed: float # Movement speed modifier
@export var terror_energy: int # Resource dropped upon defeat
@export var waypoints_node: Node2D # Reference to the Waypoints parent node
@export var core_damage: int = 10 # Damage dealt to the player's core upon reaching it

# Runtime state variables
var waypoints: Array[Vector2] = []
var current_fear_bar: int 
var current_waypoint_index: int = 0
var is_fleeing: bool = false
var _defeat_reward_emitted: bool = false
var stun_timer: float = 0.0 # Timer for Whisper room trap stun effect

func _ready() -> void:
	# Initialize base stats
	current_fear_bar = max_fear_bar
	add_to_group("enemy")
	
	# Populate waypoints array with global coordinates
	if waypoints_node:
		for waypoint: Node2D in waypoints_node.get_children():
			waypoints.append(waypoint.global_position)

func _physics_process(_delta: float) -> void:
	
	# --- STUN SYSTEM (From Whisper Trap) ---
	if stun_timer > 0:
		stun_timer -= _delta
		return # # Halt all movement and pathing while stunned
		
	# Guard clause: Ensure pathing data exists
	if waypoints.is_empty():
		printerr("Error: Waypoints array is empty.")
		return
	
	# Despawn the enemy if they successfully flee back to the start
	if is_fleeing and current_waypoint_index < 0:
		queue_free()
		return
	
	# Check if the entity has reached the final destination
	if not is_fleeing and current_waypoint_index >= waypoints.size():
		reach_core()
		return
	
	# Calculate trajectory and move towards the active waypoint
	var next_waypoint: Vector2 = waypoints[current_waypoint_index]
	var direction: Vector2 = (next_waypoint - global_position).normalized()
	
	# Enemies run 50% faster when terrified
	var current_speed: float = speed * 1.5 if is_fleeing else speed
	
	velocity = direction * current_speed
	move_and_slide()
	
	# Proceed to the next waypoint upon reaching the distance threshold
	if global_position.distance_to(next_waypoint) < 6.7:
		if is_fleeing:
			current_waypoint_index -= 1
		else:
			current_waypoint_index += 1

func take_fear_damage(amount: int, damage_source: String = "ghost") -> void:
	if is_fleeing:
		return 
	current_fear_bar -= amount
	if current_fear_bar < 0:
		current_fear_bar = 0
	print(name, " menerima ", amount, " Fear Damage dari ", damage_source, "! Sisa HP Mental: ", current_fear_bar)
	if current_fear_bar <= 0:
		trigger_flee()
		
func trigger_flee() -> void:
	if not _defeat_reward_emitted:
		_defeat_reward_emitted = true
		defeated.emit(terror_energy)
	is_fleeing = true
	current_fear_bar = 0
	current_waypoint_index -= 1 # Turn around immediately
# Handles logic when the entity reaches the player's core
func reach_core() -> void:
	# Apply final velocity to ensure collision overlap with Core's Area2D
	#move_and_slide()
	#print("Core Reached!")
	return

# Applies stun effect from Whisper room interaction
func apply_stun(duration: float) -> void:
	stun_timer = duration
