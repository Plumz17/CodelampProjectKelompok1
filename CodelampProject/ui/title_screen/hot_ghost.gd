extends TextureRect

@export var speed: float
@export var height: float
var original_y: float

func _ready() -> void:
	original_y = position.y
	start_bob()

func start_bob() -> void:
	await get_tree().create_timer(randf_range(0.0, 0.5)).timeout
	var bob_tween = create_tween()
	bob_tween.set_loops()
	bob_tween.set_ease(Tween.EASE_IN_OUT)
	bob_tween.set_trans(Tween.TRANS_SINE)
	if !height:
		height = randf_range(6.0, 14.0)   # random bob height
	if !speed:
		speed = randf_range(0.8, 1.3)     # random cycle speed
	bob_tween.tween_property(self, "position:y", original_y - height, speed)
	bob_tween.tween_property(self, "position:y", original_y, speed)
