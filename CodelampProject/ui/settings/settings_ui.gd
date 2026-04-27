extends Control

func _ready() -> void:
	SignalHub.show_settings.connect(show_settings)
	SignalHub.hide_settings.connect(hide_settings)

func show_settings():
	show()

func hide_settings():
	hide()
