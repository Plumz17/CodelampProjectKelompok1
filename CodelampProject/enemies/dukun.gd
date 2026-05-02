extends EnemyBase
class_name Dukun

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Test the inheritence (Remove later)
	super._ready()
	print("Fear: %s, Speed: %s, Terror: %s" % [max_fear_bar, speed, terror_energy])

# Cooldown timer for the active stun skill
var skill_cooldown_timer: float = 0.0

func _process(delta: float) -> void:
	# Do not cast skills if the Dukun is fleeing
	if is_fleeing: 
		return 
		
	# Process the active skill cooldown
	if skill_cooldown_timer > 0:
		skill_cooldown_timer -= delta
	else:
		cast_disable_skill()

# Overrides the base class function to apply Dukun's tank passive
func take_fear_damage(amount: int, damage_source: String = "ghost") -> void:
	# Passive: Halve ALL incoming fear damage (from ghosts or rooms)
	amount = int(amount / 2.0)
	print(name, " passive triggered! Damage from ", damage_source, " halved to: ", amount)
	
	super.take_fear_damage(amount, damage_source)

# Active Skill: Area of Effect (AoE) Stun
func cast_disable_skill() -> void:
	var nearest_ghost: Node2D = null
	var nearest_distance: float = INF
	var skill_range: float = 250.0 
	
	# Scan for all ghosts currently placed on the map
	for node in get_tree().get_nodes_in_group("ghost"):
		if node.get("is_placed") == true:
			var distance = global_position.distance_to(node.global_position)
			# Find the closest ghost within the skill range
			if distance <= skill_range and distance < nearest_distance:
				nearest_ghost = node
				nearest_distance = distance
				
	# If a valid target is found, apply a 2-second stun
	if nearest_ghost and nearest_ghost.has_method("apply_disable"):
		nearest_ghost.apply_disable(2.0)
		print(name, " casted a 2-second stun on: ", nearest_ghost.name)
	
	# Reset the skill cooldown to 20 seconds
	skill_cooldown_timer = 20.0
