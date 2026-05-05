extends Control
@onready var texture_button: TextureButton = $TextureButton
@onready var label: Label = $TextureButton/Label
@export var level_index: int
@export var speed: float
@export var height: float
@export var is_back_button: bool = false
var original_y: float
var original_scale: Vector2
const MAIN = preload("uid://bsnmbo85eivk8")

func _ready() -> void:
	original_y = texture_button.position.y
	original_scale = texture_button.scale
	setup_signals()
	start_bob()
	if label:
		label.text = str(level_index + 1)

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
	bob_tween.tween_property(texture_button, "position:y", original_y - height, speed)
	bob_tween.tween_property(texture_button, "position:y", original_y, speed)

func _on_button_hovered() -> void:
	print("Test")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(texture_button, "scale", original_scale * 1.1, 0.2)
	AudioManager.playsfx_hover()

func _on_button_unhovered() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(texture_button, "scale", original_scale, 0.2)

func _on_button_pressed() -> void:
	if is_back_button: # this code runs when back button is click
		AudioManager.playsfx_cancel()
		SignalHub.emit_hide_level_select()
	else: # this code runs when level button is clicked
		AudioManager.playsfx_click()
		GameManager.set_current_level_index(level_index)
		get_tree().change_scene_to_file("res://main.tscn")

func setup_signals() -> void:
	texture_button.pressed.connect(_on_button_pressed)
	texture_button.mouse_entered.connect(_on_button_hovered)
	texture_button.mouse_exited.connect(_on_button_unhovered)
