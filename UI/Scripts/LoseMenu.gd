extends Control

class_name LoseUI

signal retry


@export var levelController: LevelController
@export var adv_time: float = 1.25

@onready var retryButton: Button = %Retry
@onready var scoreLabel: Label = %Score
@onready var highScoreLabel: Label = %HighScore

var score: int

func _ready() -> void:
	retryButton.pressed.connect(_on_retry_pressed)
	levelController.lost.connect(_on_lose)


func _on_lose():
	var highscore = ScoreStorage.getPlayerScore()
	if highscore < levelController.score:
		highscore = levelController.score
		ScoreStorage.setPlayerScore(highscore)
	visible = true
	scoreLabel.text = tr("SCORE") % levelController.score
	highScoreLabel.text = tr("HIGHSCORE") % highscore
	await _ad_coroutine()


func _ad_coroutine():
	retryButton.visible = false
	get_tree().paused = true
	await get_tree().create_timer(adv_time, true, false, true).timeout
	Yandex.showFullscreenAdv("fullscreenAdv_on_lose")
	if levelController.loseSound.playing:
		await levelController.loseSound.finished
	Audio.stop_all_but_bg()
	if Yandex.current_fullscreen_ad_name != "":
		await Yandex._showFullscreenAdv
	retryButton.visible = true
	retryButton.grab_focus()


func _on_retry_pressed():
	get_tree().paused = false
	visible = false
	levelController.restart()
