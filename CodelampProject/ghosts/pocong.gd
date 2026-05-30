extends GhostBase
class_name Pocong

const STOMP_RANGE: float = 240.0
const STOMP_MAX_TARGETS: int = 4
const STOMP_FEAR_DAMAGE: float = 35.0
const STOMP_PUSH_STEPS: int = 2

func _ready() -> void:
	name = "Pocong"
	ability_name = "Haunted Stomp"
	ability_start_cooldown = 10.0
	ability_cooldown = 90.0
	super._ready()
	print("%s, %s, %s, %s, %s" % [fear_damage, attack_rate, cost, cost_upgrade, cost_move])
	anim_sprite.play("idle")

func _activate_ability() -> bool:
	var enemies_in_range: Array[EnemyBase] = []
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is EnemyBase:
			var enemy := node as EnemyBase
			if enemy.is_fleeing:
				continue
			if global_position.distance_to(enemy.global_position) <= STOMP_RANGE:
				enemies_in_range.append(enemy)
	enemies_in_range.sort_custom(
		func(a: EnemyBase, b: EnemyBase):
			var dist_a := global_position.distance_to(a.global_position)
			var dist_b := global_position.distance_to(b.global_position)
			return dist_a < dist_b
	)
	var hit_count: int = mini(STOMP_MAX_TARGETS, enemies_in_range.size())
	if hit_count <= 0:
		return false
	for i in range(hit_count):
		var enemy := enemies_in_range[i]
		enemy.stumble_back(STOMP_PUSH_STEPS)
		enemy.take_fear_damage(STOMP_FEAR_DAMAGE, ability_name)
	return true

func _play_attack_animation() -> void:
	if anim_sprite.animation != "attack" or !anim_sprite.is_playing():
		anim_sprite.play("attack")
		anim_sprite.animation_finished.connect(
			func(): anim_sprite.play("idle"), CONNECT_ONE_SHOT
		)
