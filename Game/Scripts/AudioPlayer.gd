extends Node

@export var masterVolume:float = 1

@onready var bgMusicPlayer = $Background as AudioStreamPlayer

var currentMultiplier = 1


func _ready() -> void:
	_on_volume_changed(masterVolume)
	
func _on_volume_changed(volume: float):
	masterVolume = volume
	AudioServer.set_bus_volume_db(0, linear_to_db(masterVolume))

func play_sound(stream: AudioStreamPlayer):
	stream.play()
	
func _on_score_changed(_score: int, multiplier: float):
	"""
	##changes the tempo of background music with score multiplier increase
	if currentMultiplier != multiplier:
		currentMultiplier = multiplier
		bgMusicPlayer.pitch_scale += currentMultiplier/100
	"""
	pass
