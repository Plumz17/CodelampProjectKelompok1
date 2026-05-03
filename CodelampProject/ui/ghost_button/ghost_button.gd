extends TextureButton

@export var ghost_scene: PackedScene
@export var ghost_group: Node2D
@export var ghost_type: String = ""  # e.g. "Pocong", "Kuntilanak", "Tuyul"

func _ready() -> void:
	button_down.connect(_on_pressed)

func _on_pressed() -> void:
	if ghost_group == null or ghost_scene == null:
		return
	var main_node := get_tree().current_scene
	var ghost_preview = ghost_scene.instantiate()
	if ghost_preview is GhostBase:
		var ghost_base := ghost_preview as GhostBase
		var ghost_cost: int = ghost_base.cost
		ghost_preview.queue_free()
		if main_node and main_node.has_method("try_spend_terror_energy"):
			if not main_node.try_spend_terror_energy(ghost_cost):
				return
	else:
		ghost_preview.queue_free()
	var new_ghost = ghost_scene.instantiate()
	ghost_group.add_child(new_ghost)
	# Spawn at mouse position (not button position)
	new_ghost.global_position = get_global_mouse_position()
	# FORCE it into dragging state
	new_ghost.dragging = true
	new_ghost.drag_offset = Vector2.ZERO
