extends Area2D
class_name GhostBase

@export var fear_damage: float #Ghost Damage
@export var attack_rate: float #Time between attacks
@export var cost: int
@export var cost_upgrade: int
@export var cost_move: int

var dragging : bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2

# Some booleans to check whether ghost can be placed
var can_place: bool = false
var in_placement_area: bool = false
var overlapping_ghost: bool = false

func _ready():
	#Set original position
	original_position = global_position

func _process(_delta: float) -> void:
	#Move position with mouse if dragging
	if dragging:
		z_index = 1
		global_position = get_global_mouse_position() + drag_offset
		# Change Color if can place/not
		if can_place:
			modulate = Color.GREEN
		else:
			modulate = Color.RED
	else:
		z_index = 0
		modulate = Color.WHITE

func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	# Start Dragging
	if not viewport.is_input_handled() and event.is_action_pressed("click"):
		dragging = true
		drag_offset = global_position - get_global_mouse_position()
	
func _unhandled_input(event: InputEvent) -> void:
	#Stop Dragging
	if event.is_action_released("click"):
		dragging = false
		place_ghost()

#Tries to place ghost
func place_ghost() -> void:
	#If can't place return to default poisition
	if !can_place:
		global_position = original_position
	else: #when placed, set default position as the current position
		original_position = global_position

func _on_area_entered(area: Area2D) -> void:
	if area is GhostBase and area.in_placement_area:
		overlapping_ghost = true
	if area.is_in_group("placement_area"):
		in_placement_area = true
	can_place = in_placement_area and not overlapping_ghost

func _on_area_exited(area: Area2D) -> void:
	if area is GhostBase:
		overlapping_ghost = false
	if area.is_in_group("placement_area"):
		in_placement_area = false
	can_place = in_placement_area and not overlapping_ghost
