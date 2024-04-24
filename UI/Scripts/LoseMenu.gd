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
	get_tree().paused = true
	visible = true
	retryButton.grab_focus()
	scoreLabel.text = tr("SCORE") % levelController.score

func _on_retry_pressed():
	get_tree().paused = false
	visible = false
	levelController.restart()
