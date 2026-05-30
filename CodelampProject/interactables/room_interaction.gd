extends Area2D
class_name RoomInteraction

var cost_lampu: int = 30
var cooldown_lampu: float = 10.0
var is_lampu_ready: bool = true

var cost_bisikan: int = 20
var cooldown_bisikan: float = 8.0
var is_bisikan_ready: bool = true

@onready var dark_effect: ColorRect = $DarkEffect

# --- Lamp Button Nodes ---
@onready var btn_lampu: TextureButton = $LampButton
@onready var label_lampu: Label = $LampButton/Label
@onready var anim_lampu: AnimatedSprite2D = $LampButton/AnimatedSprite2D

# --- Whisper Button Nodes ---
@onready var btn_bisikan: TextureButton = $WhisperButton
@onready var label_bisikan: Label = $WhisperButton/Label
@onready var anim_bisikan: AnimatedSprite2D = $WhisperButton/AnimatedSprite2D

# --- Transform Animation Variables ---
var original_lampu_scale: Vector2
var lampu_pulse_tween: Tween

var original_bisikan_scale: Vector2
var bisikan_pulse_tween: Tween

func _ready() -> void:
	dark_effect.hide()

	# Only store the original scale, WITHOUT modifying position or pivot!
	original_lampu_scale = btn_lampu.scale
	original_bisikan_scale = btn_bisikan.scale
	
	# Connect Lamp interaction signals
	btn_lampu.mouse_entered.connect(_on_lamp_hover)
	btn_lampu.mouse_exited.connect(_on_lamp_unhover)
	btn_lampu.button_down.connect(_on_lamp_down)
	
	# Connect Whisper interaction signals
	btn_bisikan.mouse_entered.connect(_on_whisper_hover)
	btn_bisikan.mouse_exited.connect(_on_whisper_unhover)
	btn_bisikan.button_down.connect(_on_whisper_down)
	
	# Initial game state (Ready to use)
	_set_lamp_state_ready()
	_start_idle_pulse_lampu()
	
	_set_bisikan_state_ready()
	_start_idle_pulse_bisikan()

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

# ==========================================
# FEATURE 1: TURN OFF LAMP
# ==========================================
func _on_lamp_button_pressed() -> void:
	if not is_lampu_ready: return
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
	
	# Kill lamp pulse animation
	if lampu_pulse_tween: lampu_pulse_tween.kill()
	btn_lampu.scale = original_lampu_scale
	
	# --- CHANGE VISUALS TO COOLDOWN ---
	anim_lampu.hide()                 
	btn_lampu.self_modulate.a = 1.0   
	btn_lampu.modulate.a = 0.6        
	
	await get_tree().create_timer(cooldown_lampu).timeout
	
	# --- RETURN TO READY STATE ---
	is_lampu_ready = true
	btn_lampu.disabled = false
	_set_lamp_state_ready()
	_start_idle_pulse_lampu()

func _set_lamp_state_ready() -> void:
	anim_lampu.show()                 
	anim_lampu.play("default")        
	btn_lampu.self_modulate.a = 0.0   
	btn_lampu.modulate.a = 1.0        

# --- LAMP BUTTON TRANSFORM ANIMATION ---
func _start_idle_pulse_lampu() -> void:
	if not is_lampu_ready: return
	if lampu_pulse_tween: lampu_pulse_tween.kill()
	
	lampu_pulse_tween = create_tween().set_loops()
	lampu_pulse_tween.tween_property(btn_lampu, "scale", original_lampu_scale * 1.05, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	lampu_pulse_tween.tween_property(btn_lampu, "scale", original_lampu_scale, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_lamp_hover() -> void:
	if not is_lampu_ready: return 
	if lampu_pulse_tween: lampu_pulse_tween.kill()
	var tween = create_tween()
	tween.tween_property(btn_lampu, "scale", original_lampu_scale * 1.15, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_lamp_unhover() -> void:
	if not is_lampu_ready: return
	var tween = create_tween()
	tween.tween_property(btn_lampu, "scale", original_lampu_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_start_idle_pulse_lampu()

func _on_lamp_down() -> void:
	if not is_lampu_ready: return
	var tween = create_tween()
	tween.tween_property(btn_lampu, "scale", original_lampu_scale * 0.8, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(btn_lampu, "scale", original_lampu_scale * 1.2, 0.1).set_trans(Tween.TRANS_BACK)
	tween.tween_property(btn_lampu, "scale", original_lampu_scale, 0.1)


# ==========================================
# FEATURE 2: WHISPER
# ==========================================
func _on_whisper_button_pressed() -> void:
	if not is_bisikan_ready: return
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
	
	# Kill heartbeat pulse animation
	if bisikan_pulse_tween: bisikan_pulse_tween.kill()
	btn_bisikan.scale = original_bisikan_scale
	
	# --- CHANGE VISUALS TO COOLDOWN ---
	anim_bisikan.hide()               
	btn_bisikan.self_modulate.a = 1.0 
	btn_bisikan.modulate.a = 0.6      
	
	await get_tree().create_timer(cooldown_bisikan).timeout
	
	# --- RETURN TO READY STATE ---
	is_bisikan_ready = true
	btn_bisikan.disabled = false
	_set_bisikan_state_ready()
	_start_idle_pulse_bisikan()

func _set_bisikan_state_ready() -> void:
	anim_bisikan.show()               
	anim_bisikan.play("default")      
	btn_bisikan.self_modulate.a = 0.0 
	btn_bisikan.modulate.a = 1.0      

# ==========================================
# WHISPER BUTTON TRANSFORM ANIMATION
# ==========================================
func _start_idle_pulse_bisikan() -> void:
	if not is_bisikan_ready: return
	if bisikan_pulse_tween: bisikan_pulse_tween.kill()
	
	bisikan_pulse_tween = create_tween().set_loops()
	bisikan_pulse_tween.tween_property(btn_bisikan, "scale", original_bisikan_scale * 1.05, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bisikan_pulse_tween.tween_property(btn_bisikan, "scale", original_bisikan_scale, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_whisper_hover() -> void:
	if not is_bisikan_ready: return 
	if bisikan_pulse_tween: bisikan_pulse_tween.kill()
	var tween = create_tween()
	tween.tween_property(btn_bisikan, "scale", original_bisikan_scale * 1.15, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_whisper_unhover() -> void:
	if not is_bisikan_ready: return
	var tween = create_tween()
	tween.tween_property(btn_bisikan, "scale", original_bisikan_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_start_idle_pulse_bisikan()

func _on_whisper_down() -> void:
	if not is_bisikan_ready: return
	var tween = create_tween()
	tween.tween_property(btn_bisikan, "scale", original_bisikan_scale * 0.8, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(btn_bisikan, "scale", original_bisikan_scale * 1.2, 0.1).set_trans(Tween.TRANS_BACK)
	tween.tween_property(btn_bisikan, "scale", original_bisikan_scale, 0.1)
