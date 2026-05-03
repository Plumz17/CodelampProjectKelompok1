extends GhostBase
class_name Kuntilanak

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "kuntilanak"
	#Test the inheritence (Remove later)
	super._ready()
	print("%s, %s, %s, %s, %s" % [fear_damage, attack_rate, cost, cost_upgrade, cost_move])
