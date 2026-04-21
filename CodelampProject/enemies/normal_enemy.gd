extends EnemyBase
class_name NormalEnemy

@export var target_marker: Marker2D
@export var follow_speed: float = 5.0
@export var normal_speed: float = 100.0  # NormalEnemy-specific speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = normal_speed  # Assign to base class speed before super._ready() uses it
	super._ready()
	print("Fear: %s, Speed: %s, Terror: %s" % [max_fear_bar, speed, terror_energy])
	
# Following their Marker2D(s)
func _physics_process(delta: float) -> void:
	if target_marker:
		# Move smoothly towards the marker
		global_position = global_position.lerp(target_marker.global_position, follow_speed * delta)
	else:
		# Fall back to waypoint movement
		super._physics_process(delta)
