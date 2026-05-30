extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SignalHub.auto_open_level_select == true:
		SignalHub.auto_open_level_select = false 
		SignalHub.show_level_select.emit() 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
