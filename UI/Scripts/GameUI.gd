extends Control

class_name GameUI

signal healthChanged(healthValue)
signal scoreChanged(score: int, multiplier: float)

@export var levelController: LevelController
@export var pauseMenu: PauseUI

@onready var healthNode: HealthUI = %HealthUI
@onready var scoreNode: ScoreUI = %ScoreUI
@onready var pauseButton: Button = %MenuButton


func _ready() -> void:
	if levelController != null:
		if levelController.has_signal("player_hit"):
			levelController.player_hit.connect(_on_player_hit)
		if levelController.has_signal("score_changed"):
			levelController.score_changed.connect(_on_score_changed)
		if levelController.has_signal("restarting"):
			levelController.restarting.connect(_on_restart)
	pauseMenu.update_language.connect(scoreNode.lang_update)
	scoreChanged.connect(scoreNode._on_game_ui_score_changed)
	healthChanged.connect(healthNode._on_update_health)
	pauseButton.pressed.connect(pauseMenu._on_resume_pressed)
	_on_player_hit(2)


func _on_player_hit(newHealth: float):
	healthChanged.emit(newHealth)


func _on_score_changed(score: int, multiplier: float):
	scoreChanged.emit(score, multiplier)


func _on_restart():
	_on_player_hit(2)
	_on_score_changed(0,levelController.defaultSpeed)
