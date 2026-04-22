extends Area2D
@export var game_over_menu: CanvasLayer
var max_hp: int = 10
var current_hp: int

func _ready() -> void:
	current_hp = max_hp 
	
	# Connect the collision signal to handle incoming entities
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Filter collisions to only process entities within the "enemy" group 
	if body.is_in_group("enemy"):
		current_hp -= 10
		print("HP Player berkurang: ", current_hp)
		
		# Remove the enemy instance to prevent multiple collision triggers
		body.queue_free()
		
		# Evaluate game state for defeat condition 
		if current_hp <= 0:
			trigger_game_over()

func trigger_game_over() -> void:
	current_hp = 0
	print("GAME OVER TER-TRIGGER!") 
	if game_over_menu:
		game_over_menu.show_game_over()
	#
