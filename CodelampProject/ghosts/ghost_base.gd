extends Area2D
class_name GhostBase
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var id: String
@export var fear_damage: float #Ghost Damage
@export var attack_rate: float #Time between attacks
@export var cost: int
@export var cost_upgrade: int
@export var cost_move: int
@export var attack_range: float = 180.0
@onready var placement_area_detector: Area2D = $PlacementAreaDetector

var dragging : bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2
var last_valid_position: Vector2
var disable_timer: float = 0.0 # ghost stun

# Some booleans to check whether ghost can be placed
var can_place: bool = false
var in_placement_area: bool = false
var overlapping_ghost: bool = false
var is_placed: bool = false
var attack_cooldown: float = 0.0

func _ready():
	
	add_to_group("ghost")
	#Set original position
	original_position = global_position
	last_valid_position = global_position
	placement_area_detector.area_entered.connect(_on_area_entered)
	placement_area_detector.area_exited.connect(_on_area_exited)
	

func _process(delta: float) -> void:
	#Move position with mouse if dragging
	if dragging:
		z_index = 1
		global_position = get_global_mouse_position() + drag_offset
		# Change Color if can place/not
		if can_place:
			modulate = Color.GREEN
		else:
			modulate = Color.RED
		if Input.is_action_just_released("click"):
			dragging = false
			place_ghost()
	else:
		z_index = 0
		modulate = Color.WHITE
	
	if is_placed:
		
		if disable_timer > 0.0:
			disable_timer -= delta
			# Visual indicator for stun (pale blue tint)
			modulate = Color(0.5, 0.5, 1.0) 
			# Skip attack logic while stunned
			return 
		else:
			# Reset color to normal
			modulate = Color.WHITE
		
		if attack_cooldown > 0.0:
			attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			var target := _find_target_in_range()
			if target:
				target.take_fear_damage(fear_damage, id)
				attack_cooldown = attack_rate
				_play_attack_animation()
			else:
				# No target found, stop attack animation and return to idle
				if anim_sprite.animation == "attack" and anim_sprite.is_playing():
					anim_sprite.stop()
					anim_sprite.play("idle")

# Allow ghost to be dragged again after placing
func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Start Dragging
	if not viewport.is_input_handled() and event.is_action_pressed("click"):
		dragging = true
		drag_offset = global_position - get_global_mouse_position()
	
#func _unhandled_input(event: InputEvent) -> void:
	##Stop Dragging
	#if dragging and event.is_action_released("click"):
		#dragging = false
		#place_ghost()

#Tries to place ghost
func place_ghost() -> void:
	#If can't place return to default poisition
	if !can_place:
		if is_placed:
			global_position = last_valid_position
		else:
			queue_free()
	else: 
		is_placed = true
		anim_sprite.play("idle")
		last_valid_position = global_position
		attack_cooldown = 0.0

func _find_target_in_range() -> EnemyBase:
	var nearest: EnemyBase = null
	var nearest_distance := INF
	for node in get_tree().get_nodes_in_group("enemy"):
		if node is EnemyBase:
			var enemy := node as EnemyBase
			var distance := global_position.distance_to(enemy.global_position)
			if distance <= attack_range and distance < nearest_distance:
				nearest = enemy
				nearest_distance = distance
	return nearest

func _on_area_entered(area: Area2D) -> void:
	print("test")
	if area is GhostBase and area.in_placement_area:
		overlapping_ghost = true
	if area.is_in_group("placement_area"):
		in_placement_area = true
	print("OG: %s, INPA: %s" % [overlapping_ghost, in_placement_area])
	can_place = in_placement_area and not overlapping_ghost

func _on_area_exited(area: Area2D) -> void:
	if area is GhostBase:
		overlapping_ghost = false
	if area.is_in_group("placement_area"):
		in_placement_area = false
	can_place = in_placement_area and not overlapping_ghost
	
# stun effect to the ghost for a specific duration
func apply_disable(duration: float) -> void:
	disable_timer = duration

func _play_attack_animation() -> void: #inherit attack animation masing2 hantu
    pass

func _on_attack_animation_finished() -> void: #inherit stop animasi saat musuh defeated
    pass
