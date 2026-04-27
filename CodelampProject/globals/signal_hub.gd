extends Node

signal show_settings
signal hide_settings

func emit_show_settings() -> void:
	show_settings.emit()

func emit_hide_settings() -> void:
	hide_settings.emit()
