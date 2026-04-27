extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	SignalHub.show_settings.connect(show_settings)
	SignalHub.hide_settings.connect(hide_settings)

func show_settings():
	show()
	animation_player.play("show")

func hide_settings():
	animation_player.play("hide")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		hide()
