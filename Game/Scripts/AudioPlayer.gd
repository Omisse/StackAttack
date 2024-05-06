extends Node

@export var masterVolume:float = 1

@onready var bgMusicPlayer = $Background as AudioStreamPlayer

var currentMultiplier = 1


func _ready() -> void:
	_on_volume_changed(masterVolume)
	#get_window().focus_exited.connect(_on_lose_focus)
	#get_window().focus_entered.connect(_on_focus)


func _notification(what: int) -> void:
	if what == Viewport.NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_on_focus()
	elif what == Viewport.NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_on_lose_focus()

func _on_lose_focus():
	pause_all()

func _on_focus():
	resume_all()


func _on_volume_changed(volume: float):
	masterVolume = volume
	AudioServer.set_bus_volume_db(0, linear_to_db(masterVolume))

func play_sound(stream: AudioStreamPlayer):
	stream.play()

func pause_all():
	for node in get_children():
		var stream = node as AudioStreamPlayer
		stream.stream_paused = true
	
func resume_all():
	for node in get_children():
		var stream = node as AudioStreamPlayer
		stream.stream_paused = false

func stop_all_but_bg():
	for node in get_children():
		if node != bgMusicPlayer:
			var stream = node as AudioStreamPlayer
			stream.stop()

func _on_score_changed(_score: int, multiplier: float):
	##changes the tempo of background music with score multiplier increase
	#if currentMultiplier != multiplier:
	#	currentMultiplier = multiplier
	#	bgMusicPlayer.pitch_scale += currentMultiplier/100
	pass
