extends Area2D

var max_hp: int = 10
var current_hp: int

func _ready() -> void:
	current_hp = max_hp 
	# Menghubungkan sinyal deteksi
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Menggunakan "label" enemy (Group) untuk deteksi 
	if body.is_in_group("enemy"):
		current_hp -= 10
		print("HP Player berkurang: ", current_hp)
		
		# Hapus musuh setelah mengenai core
		body.queue_free()
		
		# Cek kondisi Game Over 
		if current_hp <= 0:
			trigger_game_over()

func trigger_game_over() -> void:
	current_hp = 0
	print("GAME OVER TER-TRIGGER!") 
	# Tambahkan logika UI Game Over di sini nantinya
