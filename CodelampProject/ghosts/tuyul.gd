extends GhostBase
class_name Tuyul

const STEAL_RANGE: float = 300.0
const STEAL_BONUS_DAMAGE: float = 10.0

func _ready() -> void:
	name = "tuyul"
	ability_name = "Steal"
	ability_start_cooldown = 10.0
	ability_cooldown = 270.0
	ability_duration = 12.0
	super._ready()
	print("%s, %s, %s, %s, %s" % [fear_damage, attack_rate, cost, cost_upgrade, cost_move])

func _activate_ability() -> bool:
	var buffed_ghosts: Array[GhostBase] = []
	for node in get_tree().get_nodes_in_group("ghost"):
		if node is GhostBase:
			var ghost := node as GhostBase
			if not ghost.is_placed:
				continue
			if global_position.distance_to(ghost.global_position) <= STEAL_RANGE:
				ghost.fear_damage += STEAL_BONUS_DAMAGE
				buffed_ghosts.append(ghost)
	if buffed_ghosts.is_empty():
		return false
	var enemy_count := get_tree().get_nodes_in_group("enemy").size()
	var main_node := get_tree().current_scene
	if main_node and main_node.has_method("start_tuyul_steal_bonus"):
		main_node.start_tuyul_steal_bonus(ability_duration, enemy_count)
	_revert_buff_after_duration(buffed_ghosts)
	return true

func _revert_buff_after_duration(buffed_ghosts: Array[GhostBase]) -> void:
	await get_tree().create_timer(ability_duration).timeout
	for ghost in buffed_ghosts:
		if is_instance_valid(ghost):
			ghost.fear_damage -= STEAL_BONUS_DAMAGE
