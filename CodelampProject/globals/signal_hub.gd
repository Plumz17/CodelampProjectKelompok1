extends Node

signal show_settings
signal hide_settings
signal show_level_select
signal hide_level_select

func emit_show_settings() -> void:
	show_settings.emit()

func emit_hide_settings() -> void:
	hide_settings.emit()

func emit_show_level_select() -> void:
	show_level_select.emit()

func emit_hide_level_select() -> void:
	hide_level_select.emit()
