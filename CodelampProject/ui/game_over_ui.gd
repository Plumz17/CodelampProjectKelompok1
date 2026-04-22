extends CanvasLayer

func show_game_over() -> void:
	visible = true 
	get_tree().paused = true 

func _on_button_pressed() -> void:
	get_tree().paused = false 
	get_tree().reload_current_scene()
