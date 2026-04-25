extends TextureButton
class_name GameButton
@export var action_id: String

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if action_id.to_lower() == "new_game":
		get_tree().change_scene_to_file("res://main.tscn")
