extends GhostBase
class_name Kuntilanak

const SCREAM_RANGE: float = 280.0
const SCREAM_FEAR_DAMAGE: float = 25.0

func _ready() -> void:
	name = "kuntilanak"
	ability_name = "Dreadful Scream"
	ability_start_cooldown = 20.0
	ability_cooldown = 180.0
	ability_duration = 5.0
	super._ready()
	print("%s, %s, %s, %s, %s" % [fear_damage, attack_rate, cost, cost_upgrade, cost_move])
	anim_sprite.play("idle")

func _activate_ability() -> bool:
	var hit_any := false
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is EnemyBase:
			var enemy := node as EnemyBase
			if enemy.is_fleeing:
				continue
			if global_position.distance_to(enemy.global_position) <= SCREAM_RANGE:
				enemy.take_fear_damage(SCREAM_FEAR_DAMAGE, ability_name)
				enemy.apply_stun(ability_duration)
				hit_any = true
	return hit_any

func _play_attack_animation() -> void:
	if anim_sprite.animation != "attack" or !anim_sprite.is_playing():
		anim_sprite.play("attack")
		anim_sprite.animation_finished.connect(
			func(): anim_sprite.play("idle"), CONNECT_ONE_SHOT
		)
