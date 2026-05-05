extends Control
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect
@export var target_color: Color
var original_color: Color

func _ready() -> void:
	SignalHub.show_level_select.connect(show_level_select)
	SignalHub.hide_level_select.connect(hide_level_select)
	original_color = color_rect.color

func show_level_select():
	show()
	var show_tween = create_tween()
	show_tween.set_ease(Tween.EASE_IN_OUT)
	show_tween.set_trans(Tween.TRANS_EXPO)
	show_tween.tween_property(color_rect, "color", target_color, 0.2)
	#animation_player.play("show")

func hide_level_select():
	hide()
	color_rect.color = original_color
	#animation_player.play("hide")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		hide()
