extends Area2D
class_name RoomInteraction

var cost_lampu: int = 30
var cooldown_lampu: float = 10.0
var is_lampu_ready: bool = true

var cost_bisikan: int = 20
var cooldown_bisikan: float = 8.0
var is_bisikan_ready: bool = true

@onready var dark_effect: ColorRect = $DarkEffect
@onready var btn_lampu: Button = $LampButton
@onready var btn_bisikan: Button = $WhisperButton

func _ready() -> void:
	dark_effect.hide()
	btn_lampu.text = "Lampu (30)"
	btn_bisikan.text = "Bisikan (20)"

# ENERGY TRACKER FUNCTION
func _spend_energy(amount: int) -> bool:
	var main_node = get_tree().current_scene
	if main_node.has_method("try_spend_terror_energy"):
		return main_node.try_spend_terror_energy(amount)
		
	var current_parent = get_parent()
	while current_parent != null:
		if current_parent.has_method("try_spend_terror_energy"):
			return current_parent.try_spend_terror_energy(amount)
		current_parent = current_parent.get_parent()
		
	printerr("Warning: Terror Energy manager not found!")
	return false

# FEATURE 1: TURN OFF LAMP
func _on_lamp_button_pressed() -> void:
	if not is_lampu_ready:
		return
		
	if _spend_energy(cost_lampu):
		print("Lamp triggered! Energy reduced by 30.")
		_efek_matikan_lampu()
		_start_cooldown_lampu()
	else:
		print("Failed! Not enough Terror Energy for Lamp.")

func _efek_matikan_lampu() -> void:
	dark_effect.show()
	var targets = get_overlapping_areas() 
	for target in targets:
		if target.is_in_group("ghost") and target.has_method("apply_damage_buff"):
			target.apply_damage_buff(1.5, 5.0) 
			
	await get_tree().create_timer(5.0).timeout
	dark_effect.hide()

func _start_cooldown_lampu() -> void:
	is_lampu_ready = false
	btn_lampu.disabled = true
	await get_tree().create_timer(cooldown_lampu).timeout
	is_lampu_ready = true
	btn_lampu.disabled = false

# FEATURE 2: WHISPER
func _on_whisper_button_pressed() -> void:
	if not is_bisikan_ready:
		return
		
	if _spend_energy(cost_bisikan):
		print("Whisper triggered! Energy reduced by 20.")
		_efek_bisikan()
		_start_cooldown_bisikan()
	else:
		print("Failed! Not enough Terror Energy for Whisper.")

func _efek_bisikan() -> void:
	var targets = get_overlapping_bodies()
	for target in targets:
		if target.is_in_group("enemy"):
			if target.has_method("take_fear_damage"):
				target.take_fear_damage(10, "room")
			if target.has_method("apply_stun"):
				target.apply_stun(1.5)

func _start_cooldown_bisikan() -> void:
	is_bisikan_ready = false
	btn_bisikan.disabled = true
	await get_tree().create_timer(cooldown_bisikan).timeout
	is_bisikan_ready = true
	btn_bisikan.disabled = false
