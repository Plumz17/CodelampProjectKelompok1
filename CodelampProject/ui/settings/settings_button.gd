extends Button
class_name SettingsButton
@export var action_id: String

var original_y: float
var original_scale: Vector2
@onready var settings_ui: Control = $"../../../.."

func _ready() -> void:
	setup_signals()
	start_bob()

func start_bob() -> void:
	await get_tree().create_timer(randf_range(0.0, 0.5)).timeout
	var bob_tween = create_tween()
	bob_tween.set_loops()
	bob_tween.set_ease(Tween.EASE_IN_OUT)
	bob_tween.set_trans(Tween.TRANS_SINE)


func _on_button_hovered() -> void:
	pass

func _on_button_unhovered() -> void:
	pass

func _on_button_pressed() -> void:
	AudioManager.playsfx_cancel()
	settings_ui.hide()

func setup_signals() -> void:
	pressed.connect(_on_button_pressed)
