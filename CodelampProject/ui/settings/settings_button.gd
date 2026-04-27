extends MarginContainer
class_name SettingsButton
@export var action_id: String

var original_y: float
var original_scale: Vector2
@onready var button: Button = $Control/Button

func _ready() -> void:
	setup_signals()
	original_scale = scale

func _on_button_hovered() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(button, "scale", original_scale * 1.1, 0.4)
	AudioManager.playsfx_hover()

func _on_button_unhovered() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(button, "scale", original_scale, 0.4)

func _on_button_pressed() -> void:
	AudioManager.playsfx_cancel()
	SignalHub.emit_hide_settings()
	
func setup_signals() -> void:
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_button_hovered)
	button.mouse_exited.connect(_on_button_unhovered)
