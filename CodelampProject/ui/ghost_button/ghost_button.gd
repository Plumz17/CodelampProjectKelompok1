extends TextureButton

@export var ghost_scene: PackedScene
@export var ghost_group: Node2D
@export var ghost_type: String = ""  # e.g. "Pocong", "Kuntilanak", "Tuyul"

func _ready() -> void:
	button_down.connect(_on_pressed)

func _on_pressed() -> void:
	if ghost_group == null or ghost_scene == null:
		return
	var new_ghost = ghost_scene.instantiate()
	ghost_group.add_child(new_ghost)
	# Spawn at mouse position (not button position)
	new_ghost.global_position = get_global_mouse_position()
	# FORCE it into dragging state
	new_ghost.dragging = true
	new_ghost.drag_offset = Vector2.ZERO
	
