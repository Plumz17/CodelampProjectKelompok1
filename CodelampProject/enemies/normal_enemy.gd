extends EnemyBase
class_name NormalEnemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "normal enemy"
	#Test the inheritence (Remove later)
	super._ready()
	print("Fear: %s, Speed: %s, Terror: %s" % [max_fear_bar, speed, terror_energy])
