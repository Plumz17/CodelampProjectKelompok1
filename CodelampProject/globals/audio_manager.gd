extends Node
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

@export_category("Main Settings")
@export var ui_click: AudioStream
@export var ui_hover: AudioStream
@export var ui_cancel: AudioStream
 
func play_bgm(stream: AudioStream) -> void:
	bgm_player.stream = stream
	bgm_player.play()
	
func stop_bgm() -> void:
	bgm_player.stop()

func play_sfx(stream: AudioStream) -> void:
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.bus = "SFX"
	sfx_player.stream = stream
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)

func playsfx_click() -> void:
	play_sfx(ui_click)

func playsfx_hover() -> void:
	play_sfx(ui_hover)

func playsfx_cancel() -> void:
	play_sfx(ui_cancel)
