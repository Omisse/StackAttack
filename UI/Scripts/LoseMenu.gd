extends Control

class_name LoseUI

@export var levelController: LevelController

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
	get_tree().paused = true
	await _ad_coroutine()


func _ad_coroutine():
	retryButton.visible = false
	if levelController.loseSound.playing:
		await levelController.loseSound.finished
	Audio.stop_all_but_bg()
	await Yandex.showFullscreenAdv("fullscreenAdv_on_lose")
	retryButton.visible = true
	retryButton.grab_focus()


func _on_retry_pressed():
	get_tree().paused = false
	visible = false
	levelController.restart()
