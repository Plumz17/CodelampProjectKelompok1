extends Node2D

# ── Wave Data ────
# wave_data.gd must exist with:
#   @export var enemy_scenes: Array[PackedScene] = []
#   @export var enemy_counts: Array[int] = []
#   @export var interval: float = 1.5
@export var waves: Array[WaveData] = []

@export var spawn_point: Marker2D
@export var waypoints_node: Node2D

var _enemy_container: Node2D
var _spawn_queue: Array = []
var _active_enemies: int = 0
var _wave_in_progress: bool = false
var _current_wave_index: int = 0

var _spawn_timer: Timer

signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal all_waves_cleared

func _ready() -> void:
	_enemy_container = get_node_or_null("EnemyContainer")
	if not _enemy_container:
		_enemy_container = Node2D.new()
		_enemy_container.name = "EnemyContainer"
		add_child(_enemy_container)

	_spawn_timer = get_node_or_null("SpawnTimer")
	if not _spawn_timer:
		_spawn_timer = Timer.new()
		_spawn_timer.name = "SpawnTimer"
		add_child(_spawn_timer)

	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	var wave_button = get_node_or_null("WaveButton")
	if wave_button:
		wave_button.pressed.connect(start_next_wave)

func start_next_wave() -> void:
	if _wave_in_progress:
		printerr("Wave already in progress!")
		return
	if _current_wave_index >= waves.size():
		emit_signal("all_waves_cleared")
		print("All waves cleared!")
		return
	if not spawn_point:
		printerr("No spawn_point assigned!")
		return

	var wave_data: WaveData = waves[_current_wave_index]
	_build_spawn_queue(wave_data)

	_spawn_timer.wait_time = wave_data.interval
	_spawn_timer.start()
	_wave_in_progress = true

	emit_signal("wave_started", _current_wave_index)
	print("Wave %d started!" % (_current_wave_index + 1))

func _build_spawn_queue(wave_data: WaveData) -> void:
	_spawn_queue.clear()
	for i in wave_data.enemy_scenes.size():
		var scene: PackedScene = wave_data.enemy_scenes[i]
		var count: int = wave_data.enemy_counts[i] if i < wave_data.enemy_counts.size() else 1
		for j in count:
			_spawn_queue.append(scene)

func _on_spawn_timer_timeout() -> void:
	if _spawn_queue.is_empty():
		_spawn_timer.stop()
		return

	var enemy_scene: PackedScene = _spawn_queue.pop_front()
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()
	enemy.position = spawn_point.global_position

	if "waypoints_node" in enemy and waypoints_node:
		enemy.waypoints_node = waypoints_node

	_active_enemies += 1
	enemy.tree_exited.connect(_on_enemy_removed)
	_enemy_container.call_deferred("add_child", enemy)

func _on_enemy_removed() -> void:
	_active_enemies -= 1
	if _active_enemies <= 0 and _spawn_queue.is_empty() and _wave_in_progress:
		_wave_in_progress = false
		emit_signal("wave_cleared", _current_wave_index)
		print("Wave %d cleared!" % (_current_wave_index + 1))
		_current_wave_index += 1

		var wave_button = get_node_or_null("WaveButton")
		if wave_button:
			if _current_wave_index < waves.size():
				wave_button.text = "Start Wave %d" % (_current_wave_index + 1)
			else:
				wave_button.text = "All Done"
				wave_button.disabled = true