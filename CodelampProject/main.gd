extends Node2D

# ── Level Loading ──────────────────────────────────────────────
@export var level_scene: PackedScene

var _waypoints_node: Node2D
var _spawn_point: Marker2D
var _enemy_container: Node2D
var _level_container: Node2D
var _wave_button: Button

# ── Wave Data ──────────────────────────────────────────────────

@export var waves: Array[WaveData] = []

var _current_wave_index: int = 0
var _enemies_to_spawn: Array = []
var _spawn_queue: Array = []
var _active_enemies: int = 0
var _wave_in_progress: bool = false
var _is_preparing: bool = true

# ── Spawn Timer ────────────────────────────────────────────────
var _spawn_timer: Timer

# ── Signals ───────────────────────────────────────────────────
signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal all_waves_cleared

func _ready() -> void:
	_enemy_container = get_node_or_null("EnemyContainer") as Node2D
	_level_container = get_node_or_null("LevelContainer") as Node2D
	_spawn_timer = get_node_or_null("SpawnTimer") as Timer
	_wave_button = get_node_or_null("WaveButton") as Button

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
		_wave_button = Button.new()
		_wave_button.name = "WaveButton"
		_wave_button.text = "Start Wave 1"
		_wave_button.position = Vector2(24, 24)
		add_child(_wave_button)

	# Load level scene
	if level_scene:
		var level = level_scene.instantiate()
		_level_container.add_child(level)
		_waypoints_node = level.get_node_or_null("Waypoints")
		_spawn_point = level.get_node_or_null("SpawnPoint")
	else:
		printerr("main.gd: No level_scene assigned!")

	_spawn_timer.one_shot = false
	if not _spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	if not _wave_button.pressed.is_connected(_on_wave_button_pressed):
		_wave_button.pressed.connect(_on_wave_button_pressed)
	_update_wave_button()

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
	if _wave_in_progress:
		_wave_button.disabled = true
		_wave_button.text = "Wave %d Running" % (_current_wave_index + 1)
		return
	_wave_button.disabled = false
	if _current_wave_index >= waves.size():
		_wave_button.text = "All Waves Cleared"
		return
	if _is_preparing:
		_wave_button.text = "Start Wave %d" % (_current_wave_index + 1)
	else:
		_wave_button.text = "Prepare Wave %d" % (_current_wave_index + 1)

# ── Public: call this from a UI button ────────────────────────
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

	var interval: float = wave_data.interval
	_spawn_timer.wait_time = interval
	_spawn_timer.start()
	_wave_in_progress = true
	_is_preparing = false
	_update_wave_button()

	emit_signal("wave_started", _current_wave_index)
	print("Wave %d started!" % (_current_wave_index + 1))

# ── Build flat spawn queue from wave enemy list ───────────────
func _build_spawn_queue(wave_data: WaveData) -> void:
	_spawn_queue.clear()
	for entry in wave_data.enemies:
		for i in entry.count:
			_spawn_queue.append(entry.scene)

# ── Spawn one enemy per timer tick ───────────────────────────
func _on_spawn_timer_timeout() -> void:
	if _spawn_queue.is_empty():
		_spawn_timer.stop()
		return

	var enemy_scene: PackedScene = _spawn_queue.pop_front()
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()
	enemy.position = _spawn_point.global_position

	# Assign waypoints if the enemy uses them
	if enemy.has_method("set") and _waypoints_node:
		if "waypoints_node" in enemy:
			enemy.waypoints_node = _waypoints_node

	_active_enemies += 1
	enemy.tree_exited.connect(_on_enemy_removed)
	_enemy_container.call_deferred("add_child", enemy)

# ── Called when an enemy is removed from the scene ───────────
func _on_enemy_removed() -> void:
	_active_enemies -= 1
	# Wave is cleared when all spawned enemies are gone and queue is empty
	if _active_enemies <= 0 and _spawn_queue.is_empty() and _wave_in_progress:
		_wave_in_progress = false
		emit_signal("wave_cleared", _current_wave_index)
		print("Wave %d cleared!" % (_current_wave_index + 1))
		_current_wave_index += 1
