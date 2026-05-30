extends CharacterBody2D
class_name EnemyBase

signal defeated(terror_energy_amount: int)

@export var max_fear_bar: int # Maximum health/fear capacity
@export var speed: float # Movement speed modifier
@export var terror_energy: int # Resource dropped upon defeat
@export var waypoints_node: Node2D # Reference to the Waypoints parent node
@export var core_damage: int = 10 # Damage dealt to the player's core upon reaching it
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

# --- UI FEAR BAR ---
@onready var fear_bar_ui: ProgressBar = get_node_or_null("FearBar")

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
	
	# Initialize UI Fear Bar if the node exists
	if fear_bar_ui:
		fear_bar_ui.max_value = max_fear_bar
		fear_bar_ui.value = current_fear_bar
	
	# Populate waypoints array with global coordinates
	if waypoints_node:
		for waypoint: Node2D in waypoints_node.get_children():
			waypoints.append(waypoint.global_position)

func _physics_process(_delta: float) -> void:
	
	# --- STUN SYSTEM (From Whisper Trap) ---
	if stun_timer > 0:
		stun_timer -= _delta
		return # Halt all movement and pathing while stunned
		
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
	
	var next_waypoint: Vector2 = waypoints[current_waypoint_index]
	var to_waypoint: Vector2 = next_waypoint - global_position
	var current_speed: float = speed * 1.5 if is_fleeing else speed
	var step_distance: float = current_speed * _delta
	
	if to_waypoint.length() <= max(step_distance, 6.7):
		global_position = next_waypoint
		velocity = Vector2.ZERO
		if is_fleeing:
			current_waypoint_index -= 1
		else:
			current_waypoint_index += 1
		return
		
	var direction: Vector2 = to_waypoint.normalized()
	velocity = direction * current_speed
	move_and_slide()

	# --- Rotate System ---
	rotation = 0.0
	
	if sprite and velocity.length() > 0.1:
		# Reset vertical offset so the sprite doesn't float
		sprite.position.y = 0.0
		# Rotate only the sprite to face the movement direction
		sprite.rotation = velocity.angle() - deg_to_rad(-90)


func take_fear_damage(amount: int, damage_source: String = "ghost") -> void:
	if is_fleeing:
		return 
	current_fear_bar -= amount
	if current_fear_bar < 0:
		current_fear_bar = 0
		
	# Update the UI Fear Bar after taking damage
	if fear_bar_ui:
		fear_bar_ui.value = current_fear_bar
		
	print(name, " received ", amount, " Fear Damage from ", damage_source, "! Remaining Mental HP: ", current_fear_bar)
	if current_fear_bar <= 0:
		trigger_flee()


func trigger_flee() -> void:
	if not _defeat_reward_emitted:
		_defeat_reward_emitted = true
		defeated.emit(terror_energy)
	is_fleeing = true
	current_fear_bar = 0
	
	# Hide the Fear Bar when the enemy is fleeing (optional, for aesthetics)
	if fear_bar_ui:
		fear_bar_ui.hide()
	
	if current_waypoint_index >= waypoints.size():
		current_waypoint_index = waypoints.size() - 1
	else:
		current_waypoint_index = max(current_waypoint_index - 1, 0)

# Handles logic when the entity reaches the player's core
func reach_core() -> void:
	# Apply final velocity to ensure collision overlap with Core's Area2D
	#move_and_slide()
	#print("Core Reached!")
	return

# Applies stun effect from Whisper room interaction
func apply_stun(duration: float) -> void:
	stun_timer = duration

# Forces the enemy to move backward a certain number of steps
func stumble_back(steps: int = 1) -> void:
	if waypoints.is_empty():
		return
	if steps <= 0:
		return
	if is_fleeing:
		current_waypoint_index = max(current_waypoint_index - steps, -1)
		return
	if waypoints.size() <= 1:
		current_waypoint_index = 0
		return
	if current_waypoint_index <= 1:
		current_waypoint_index = 1
		return
	current_waypoint_index = max(current_waypoint_index - steps, 1)
