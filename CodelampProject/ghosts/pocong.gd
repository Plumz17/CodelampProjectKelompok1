extends GhostBase
class_name Pocong

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "Pocong"
	super._ready()
	print("%s, %s, %s, %s, %s" % [fear_damage, attack_rate, cost, cost_upgrade, cost_move])
	anim_sprite.play("idle")

func _play_attack_animation() -> void:
	if anim_sprite.animation != "attack" or !anim_sprite.is_playing():
		anim_sprite.play("attack")
		anim_sprite.animation_finished.connect(
			func(): anim_sprite.play("idle"), CONNECT_ONE_SHOT
		)
