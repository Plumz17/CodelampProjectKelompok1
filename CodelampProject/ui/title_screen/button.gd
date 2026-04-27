extends Control
class_name GameButton
@export var action_id: String
@export var button_group: Control
@export var texture_button: TextureButton
@export var speed: float
@export var height: float
var original_y: float
var original_scale: Vector2
@onready var vfx: AudioStreamPlayer2D = $"../../../VFX"
@onready var settings_ui: Control = $"../../../SettingsUI"

func _ready() -> void:
	original_y = button_group.position.y
	original_scale = texture_button.scale
	print("original_scale: ", original_scale)
	setup_signals()
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
	bob_tween.tween_property(button_group, "position:y", original_y - height, speed)
	bob_tween.tween_property(button_group, "position:y", original_y, speed)

func _on_button_hovered() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(texture_button, "scale", original_scale * 1.1, 0.4)
	AudioManager.playsfx_hover()

func _on_button_unhovered() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(texture_button, "scale", original_scale, 0.4)

func _on_button_pressed() -> void:
	AudioManager.playsfx_click()
	if action_id.to_lower() == "new_game":
		get_tree().change_scene_to_file("res://main.tscn")
	if action_id.to_lower() == "settings":
		settings_ui.show()

func setup_signals() -> void:
	texture_button.pressed.connect(_on_button_pressed)
	texture_button.mouse_entered.connect(_on_button_hovered)
	texture_button.mouse_exited.connect(_on_button_unhovered)
