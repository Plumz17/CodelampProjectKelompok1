extends CanvasLayer

func _ready() -> void:
	# Sembunyikan layar ini saat game baru mulai
	visible = false

# Fungsi ini yang akan dipanggil oleh main.gd
func show_victory() -> void:
	visible = true
	get_tree().paused = true # Pause game agar semuanya berhenti

# --- KONEKSIKAN TOMBOL DI BAWAH INI DARI TAB NODE -> SIGNALS ---

func _on_home_pressed() -> void:
	# Buka kunci pause sebelum pindah scene
	get_tree().paused = false 
	# Ganti dengan path ke scene menu utama kamu
	get_tree().change_scene_to_file("res://ui/title_screen/tile_screen.tscn") 
	


func _on_next_pressed() -> void:
	get_tree().paused = false
	
	# 1. Titip pesan ke SignalHub sebelum scene ini hancur
	SignalHub.auto_open_level_select = true
	
	# 2. Pindah ke scene Menu Utama kamu (sesuai nama file aslimu)
	get_tree().change_scene_to_file("res://ui/title_screen/tile_screen.tscn")
