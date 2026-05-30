extends EnemyBase
class_name NormalEnemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "normal enemy"
	
	# Call the parent class _ready() to initialize base stats and waypoints
	super._ready()
	
	# Play the walk animation as the default state upon spawning
	if sprite:
		sprite.play("walk")
		
	# Test the inheritance (Remove later when no longer needed)
	print("Fear: %s, Speed: %s, Terror: %s" % [max_fear_bar, speed, terror_energy])

# Overrides the base class function to check for the flee state
func take_fear_damage(amount: int, damage_source: String = "ghost") -> void:
	# Pass the damage amount directly to the base EnemyBase function
	super.take_fear_damage(amount, damage_source)
	
	# Check if the HP/Fear Bar is depleted after taking damage
	if current_fear_bar <= 0:
		# Change animation to flee if they are terrified
		if sprite and sprite.animation != "flee":
			sprite.play("flee")
			# speed = speed * 1.5 # Optional: Make them run faster when fleeing
