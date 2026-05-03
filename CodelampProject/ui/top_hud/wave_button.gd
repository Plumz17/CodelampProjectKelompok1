extends Button
class_name WaveButtonUI

signal start_requested

func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	start_requested.emit()

func update_wave_state(current_wave_index: int, total_waves: int, wave_in_progress: bool, is_preparing: bool) -> void:
	if wave_in_progress:
		disabled = true
		text = "Wave %d Running" % (current_wave_index + 1)
		return
	disabled = false
	if current_wave_index >= total_waves:
		text = "All Waves Cleared"
		return
	if is_preparing:
		text = "Start Wave %d" % (current_wave_index + 1)
	else:
		text = "Prepare Wave %d" % (current_wave_index + 1)
