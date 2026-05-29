extends CanvasLayer

func show_game_over() -> void:
	visible = true 
	get_tree().paused = true 

func _on_button_pressed() -> void:
	get_tree().paused = false 
	get_tree().reload_current_scene()


func _on_home_pressed() -> void:
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://ui/title_screen/tile_screen.tscn")
