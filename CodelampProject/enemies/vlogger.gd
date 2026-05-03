extends EnemyBase
class_name Vlogger

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	name = "vlogger"
	# Call the parent class _ready() to initialize base stats and waypoints
	super._ready()
	
	# Test the inheritance (Remove later when no longer needed)
	print("Vlogger Spawned -> Fear: %s, Speed: %s, Terror: %s" % [max_fear_bar, speed, terror_energy])

# Overrides the base class function to apply Vlogger's passive skill
func take_fear_damage(amount: int, damage_source: String = "ghost") -> void:
	# Passive: Halve the incoming damage if the source is a room interaction
	if damage_source == "room":
		amount = int(amount / 2.0)
		print(name, " passive triggered! Room damage halved to: ", amount)
		
	# Pass the modified amount to the base EnemyBase function
	super.take_fear_damage(amount, damage_source)
