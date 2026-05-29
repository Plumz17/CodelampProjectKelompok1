extends EnemyBase
class_name NormalEnemy

# Reference to the AnimatedSprite2D node in the scene
@onready var sprite = $AnimatedSprite2D
var _last_x_position: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "normal enemy"
	
	# Call the parent class _ready() to initialize base stats and waypoints
	super._ready()
	
	# Play the walk animation as the default state upon spawning
	if sprite:
		sprite.play("walk")
	_last_x_position = global_position.x
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

# Physics 
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not sprite:
		return
	
	if velocity.length() > 0.1:
		sprite.rotation = velocity.angle() - deg_to_rad(-90)
