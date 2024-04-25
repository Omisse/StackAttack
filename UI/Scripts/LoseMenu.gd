extends Control

class_name LoseUI

signal retry

@export var levelController: LevelController

@onready var retryButton: Button = %Retry
@onready var scoreLabel: Label = %Score

var score: int

func _ready() -> void:
	retryButton.pressed.connect(_on_retry_pressed)
	levelController.lost.connect(_on_lose)

func _on_lose():
	visible = true
	retryButton.grab_focus()
	scoreLabel.text = tr("SCORE") % levelController.score
	get_tree().paused = true
	Yandex.showFullscreenAdv("fullscreenAdv_on_lose")
	if levelController.loseSound.playing:
		await levelController.loseSound.finished
	Audio.stop_all_but_bg()
	if Yandex.current_fullscreen_ad_name != "":
		await Yandex._showFullscreenAdv

func _on_retry_pressed():
	get_tree().paused = false
	visible = false
	levelController.restart()
