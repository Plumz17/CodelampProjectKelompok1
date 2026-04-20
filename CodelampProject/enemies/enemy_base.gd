extends CharacterBody2D
class_name EnemyBase

@export var max_fear_bar: int # HP Musuh (Fear Bar) 
@export var speed: float 
@export var terror_energy: int # Resource yang didapat 
@export var waypoints_node: Node2D # Node Waypoints di Main Scene

# Variabel pergerakan
var waypoints: Array[Vector2] = []
var current_fear_bar: int 
var current_waypoint_index: int = 0

func _ready() -> void:
	# Inisialisasi HP musuh
	current_fear_bar = max_fear_bar
	
	# Ambil data semua titik jalan
	if waypoints_node:
		for waypoint: Node2D in waypoints_node.get_children():
			waypoints.append(waypoint.global_position)

func _physics_process(_delta: float) -> void:
	if waypoints.is_empty():
		return
	
	# Berhenti memproses waypoint jika sudah di titik terakhir (menunggu Core)
	if current_waypoint_index >= waypoints.size():
		reach_core()
		return
	
	# Logika pergerakan ke waypoint selanjutnya
	var next_waypoint: Vector2 = waypoints[current_waypoint_index]
	var direction: Vector2 = (next_waypoint - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Cek jika sudah dekat dengan target waypoint
	if global_position.distance_to(next_waypoint) < 6.7:
		current_waypoint_index += 1

func reach_core() -> void:
	# Biarkan musuh tetap bergerak sedikit agar masuk ke area PlayerCore
	move_and_slide()
	
	# Pencegahan spam pesan di console
	if not has_meta("reached_target"):
		print("Musuh mencapai tujuan: ", name)
		set_meta("reached_target", true)
