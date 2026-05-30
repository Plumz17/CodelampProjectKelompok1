extends Node2D

@onready var _game_over_ui = $GameOverUI

# ── Level Loading ────
#@export var level_scene: PackedScene (This will be handled in the game manager)

var _waypoints_node: Node2D
var _spawn_point: Marker2D
var _enemy_container: Node2D
var _level_container: Node2D
var _wave_button: Button
var _terror_energy_label: Label
var _terror_energy: int = 0
var _ghost_container: Node2D
var _pocong_ability_button: Button
var _kuntilanak_ability_button: Button
var _tuyul_ability_button: Button
var _tuyul_bonus_time_left: float = 0.0
var _tuyul_bonus_amount: int = 0

# ── Wave Data ────
var waves: Array[WaveData] = []
var _current_wave_index: int = 0
var _spawn_queue: Array = []
var _active_enemies: int = 0
var _wave_in_progress: bool = false
var _is_preparing: bool = true
var _last_spawn_time_in_wave: float = 0.0

# ── Spawn Timer ────
var _spawn_timer: Timer

# ── Signals ────
signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal all_waves_cleared

func _ready() -> void:
	# GameOver UI
	if _game_over_ui:
		_game_over_ui.visible = false

	_ghost_container = get_node_or_null("Ghosts") as Node2D
	_enemy_container = get_node_or_null("EnemyContainer") as Node2D
	_level_container = get_node_or_null("LevelContainer") as Node2D
	_spawn_timer = get_node_or_null("SpawnTimer") as Timer
	_wave_button = get_node_or_null("TopHUD/WaveButton") as Button
	_pocong_ability_button = get_node_or_null("GhostSelectUI/MarginContainer/VBoxContainer/AbilityButtons/PocongAbilityButton") as Button
	_kuntilanak_ability_button = get_node_or_null("GhostSelectUI/MarginContainer/VBoxContainer/AbilityButtons/KuntilanakAbilityButton") as Button
	_tuyul_ability_button = get_node_or_null("GhostSelectUI/MarginContainer/VBoxContainer/AbilityButtons/TuyulAbilityButton") as Button
	if not _wave_button:
		_wave_button = find_child("WaveButton", true, false) as Button
	_terror_energy_label = get_node_or_null("TopHUD/TerrorEnergyLabel") as Label
	if not _terror_energy_label:
		_terror_energy_label = find_child("TerrorEnergyLabel", true, false) as Label

	if not _enemy_container:
		_enemy_container = Node2D.new()
		_enemy_container.name = "EnemyContainer"
		add_child(_enemy_container)

	if not _level_container:
		_level_container = Node2D.new()
		_level_container.name = "LevelContainer"
		add_child(_level_container)

	if not _spawn_timer:
		_spawn_timer = Timer.new()
		_spawn_timer.name = "SpawnTimer"
		add_child(_spawn_timer)

	if not _wave_button:
		_wave_button = load("res://ui/top_hud/wave_button.gd").new()
		_wave_button.name = "WaveButton"
		_wave_button.text = "Start Wave 1"
		_wave_button.position = Vector2(24, 24)
		var top_hud := get_node_or_null("TopHUD") as CanvasLayer
		if not top_hud:
			top_hud = CanvasLayer.new()
			top_hud.name = "TopHUD"
			add_child(top_hud)
		top_hud.add_child(_wave_button)

	# Load level scene
	var level_scene = GameManager.get_current_level()
	if level_scene:
		var level = level_scene.instantiate()
		_level_container.add_child(level)
		_waypoints_node = level.get_node_or_null("Waypoints")
		_spawn_point = level.get_node_or_null("SpawnPoint")
		_terror_energy = level.initial_terror_energy
		waves = level.wave_data

		# Connect PlayerCore destroyed signal
		var player_core = level.get_node_or_null("PlayerCore")
		if player_core:
			player_core.connect("core_destroyed", Callable(self, "_on_player_core_destroyed"))
		else:
			printerr("main.gd: PlayerCore tidak ditemukan di level scene!")
	else:
		printerr("main.gd: No level_scene assigned in Game Manager!")

	if not _terror_energy_label:
		_terror_energy_label = load("res://ui/top_hud/energi_teror.gd").new()
		_terror_energy_label.name = "TerrorEnergyLabel"
		_terror_energy_label.position = Vector2(190, 30)
		var top_hud_for_label := get_node_or_null("TopHUD") as CanvasLayer
		if not top_hud_for_label:
			top_hud_for_label = CanvasLayer.new()
			top_hud_for_label.name = "TopHUD"
			add_child(top_hud_for_label)
		top_hud_for_label.add_child(_terror_energy_label)

	_spawn_timer.one_shot = false
	if not _spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	if _wave_button and _wave_button.has_signal("start_requested"):
		if not _wave_button.is_connected(
			"start_requested",
			Callable(self, "_on_wave_button_pressed")
		):
			_wave_button.connect(
				"start_requested",
				Callable(self, "_on_wave_button_pressed")
			)
	if _pocong_ability_button and not _pocong_ability_button.pressed.is_connected(_on_pocong_ability_button_pressed):
		_pocong_ability_button.pressed.connect(_on_pocong_ability_button_pressed)
	if _kuntilanak_ability_button and not _kuntilanak_ability_button.pressed.is_connected(_on_kuntilanak_ability_button_pressed):
		_kuntilanak_ability_button.pressed.connect(_on_kuntilanak_ability_button_pressed)
	if _tuyul_ability_button and not _tuyul_ability_button.pressed.is_connected(_on_tuyul_ability_button_pressed):
		_tuyul_ability_button.pressed.connect(_on_tuyul_ability_button_pressed)
	_update_terror_energy_label()
	_update_wave_button()

func _physics_process(delta: float) -> void:
	if _tuyul_bonus_time_left > 0.0:
		_tuyul_bonus_time_left = max(_tuyul_bonus_time_left - delta, 0.0)
		if _tuyul_bonus_time_left <= 0.0:
			_tuyul_bonus_amount = 0
	_update_ability_buttons()

func _on_wave_button_pressed() -> void:
	if _wave_in_progress:
		return
	if _current_wave_index >= waves.size():
		_update_wave_button()
		return
	if not _is_preparing:
		_is_preparing = true
		_update_wave_button()
		return
	start_next_wave()

func _update_wave_button() -> void:
	if not _wave_button:
		return
	if _wave_button.has_method("update_wave_state"):
		_wave_button.call(
			"update_wave_state",
			_current_wave_index,
			waves.size(),
			_wave_in_progress,
			_is_preparing
		)
	_update_terror_energy_label()

# ── Public: call this from a UI button ────
func start_next_wave() -> void:
	if _wave_in_progress:
		printerr("Wave already in progress!")
		return
	if _current_wave_index >= waves.size():
		print("All waves cleared!")
		emit_signal("all_waves_cleared")
		_update_wave_button()
		return
	if not _spawn_point:
		printerr("No SpawnPoint found in level scene!")
		return

	var wave_data: WaveData = waves[_current_wave_index]
	_build_spawn_queue(wave_data)
	if _spawn_queue.is_empty():
		printerr("Wave %d has no valid spawn entries!" % (_current_wave_index + 1))
		return

	var first_delay: float = max(float(_spawn_queue[0][0]), 0.0)
	_spawn_timer.wait_time = max(first_delay, 0.001)
	_spawn_timer.start()
	_wave_in_progress = true
	_is_preparing = false
	_update_wave_button()

	emit_signal("wave_started", _current_wave_index)
	print("Wave %d started!" % (_current_wave_index + 1))

# ── Build flat spawn queue from wave enemy list ────
func _build_spawn_queue(wave_data: WaveData) -> void:
	_spawn_queue.clear()
	_last_spawn_time_in_wave = 0.0
	for entry: SpawnEntry in wave_data.spawn_schedule:
		var spawn_time: float = max(entry.time_seconds, 0.0)
		var scene_index: int = int(entry.enemy_type)
		var count: int = entry.count
		if count <= 0:
			continue
		if scene_index < 0 or scene_index >= wave_data.enemy_scenes.size():
			continue
		var enemy_scene: PackedScene = wave_data.enemy_scenes[scene_index]
		if not enemy_scene:
			continue
		for i in range(count):
			_spawn_queue.append([spawn_time, enemy_scene])
		if spawn_time > _last_spawn_time_in_wave:
			_last_spawn_time_in_wave = spawn_time
	_spawn_queue.sort_custom(func(a, b): return float(a[0]) < float(b[0]))

# ── Spawn one enemy per timer tick ────
func _on_spawn_timer_timeout() -> void:
	if _spawn_queue.is_empty():
		_spawn_timer.stop()
		return

	var spawn_entry: Array = _spawn_queue.pop_front()
	if spawn_entry.size() < 2:
		return
	var spawn_time: float = float(spawn_entry[0])
	var enemy_scene: PackedScene = spawn_entry[1]
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()
	enemy.position = _spawn_point.global_position

	if enemy is EnemyBase:
		if _waypoints_node:
			enemy.waypoints_node = _waypoints_node
		if not enemy.defeated.is_connected(_on_enemy_defeated):
			enemy.defeated.connect(_on_enemy_defeated)

	_active_enemies += 1
	enemy.tree_exited.connect(_on_enemy_removed)
	_enemy_container.call_deferred("add_child", enemy)

	if _spawn_queue.is_empty():
		_spawn_timer.stop()
		return

	var next_spawn_time: float = float(_spawn_queue[0][0])
	var next_delay: float = max(next_spawn_time - spawn_time, 0.001)
	_spawn_timer.wait_time = next_delay

func _on_enemy_defeated(terror_energy_amount: int) -> void:
	_terror_energy += max(terror_energy_amount, 0)
	if _tuyul_bonus_amount > 0:
		_terror_energy += _tuyul_bonus_amount
	_update_terror_energy_label()

func start_tuyul_steal_bonus(duration: float, enemy_count: int) -> void:
	_tuyul_bonus_time_left = max(duration, 0.0)
	_tuyul_bonus_amount = clampi(enemy_count / 5, 1, 6)

func _get_placed_ghosts_by_id(ghost_id: String) -> Array[GhostBase]:
	var placed: Array[GhostBase] = []
	if not _ghost_container:
		return placed
	for node in _ghost_container.get_children():
		if node is GhostBase:
			var ghost := node as GhostBase
			if ghost.id == ghost_id and ghost.is_placed:
				placed.append(ghost)
	return placed

func _get_best_ability_owner(ghost_id: String) -> GhostBase:
	var placed := _get_placed_ghosts_by_id(ghost_id)
	if placed.is_empty():
		return null
	var selected: GhostBase = null
	for ghost in placed:
		if ghost.can_activate_ability():
			if selected == null or ghost.get_ability_cooldown_left() < selected.get_ability_cooldown_left():
				selected = ghost
	if selected:
		return selected
	selected = placed[0]
	for ghost in placed:
		if ghost.get_ability_cooldown_left() < selected.get_ability_cooldown_left():
			selected = ghost
	return selected

func _update_ability_buttons() -> void:
	_update_ability_button_state(_pocong_ability_button, "pocong")
	_update_ability_button_state(_kuntilanak_ability_button, "kuntilanak")
	_update_ability_button_state(_tuyul_ability_button, "tuyul")

func _update_ability_button_state(button: Button, ghost_id: String) -> void:
	if not button:
		return
	var owner := _get_best_ability_owner(ghost_id)
	button.disabled = owner == null or not owner.can_activate_ability()

func _on_pocong_ability_button_pressed() -> void:
	_activate_ghost_ability("pocong")

func _on_kuntilanak_ability_button_pressed() -> void:
	_activate_ghost_ability("kuntilanak")

func _on_tuyul_ability_button_pressed() -> void:
	_activate_ghost_ability("tuyul")

func _activate_ghost_ability(ghost_id: String) -> void:
	var owner := _get_best_ability_owner(ghost_id)
	if not owner:
		return
	owner.try_activate_ability()
	_update_ability_buttons()

func try_spend_terror_energy(amount: int) -> bool:
	if amount <= 0:
		return true
	if _terror_energy < amount:
		return false
	_terror_energy -= amount
	_update_terror_energy_label()
	return true

func _update_terror_energy_label() -> void:
	if not _terror_energy_label:
		return
	if _terror_energy_label.has_method("set_energi_teror"):
		_terror_energy_label.call("set_energi_teror", _terror_energy)

# ── Called when an enemy is removed from the scene ────
func _on_enemy_removed() -> void:
	_active_enemies -= 1
	if _active_enemies <= 0 and _spawn_queue.is_empty() and _wave_in_progress:
		_wave_in_progress = false
		emit_signal("wave_cleared", _current_wave_index)
		print("Wave %d cleared!" % (_current_wave_index + 1))
		_current_wave_index += 1
		_is_preparing = true
		_update_wave_button()

func _on_kuntianak_button_pressed() -> void:
	pass # Replace with function body.

# ── GameOver ────
func _on_player_core_destroyed() -> void:
	print("Sinyal Core Hancur diterima oleh Main!")

	if _spawn_timer:
		_spawn_timer.stop()

	if _game_over_ui and _game_over_ui.has_method("show_game_over"):
		_game_over_ui.show_game_over()
	else:
		if _game_over_ui:
			_game_over_ui.visible = true
		get_tree().paused = true
