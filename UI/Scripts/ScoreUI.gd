extends VBoxContainer

class_name ScoreUI

signal update_score(value : int)
signal update_difficulty(value : float)

@export var scoreText: String = "[center][font_size=28]%s[/font_size][/center]"
@export var difficultyText: String = "[center][pulse freq=1 color=#FC5130 ease=-2.0][font_size=28]%sx![/font_size][/pulse][/center]"

@onready var scoreLabel = $RichTextLabel as RichTextLabel
@onready var difficultyLabel = $RichTextLabel2 as RichTextLabel

var score:int = 0

func _ready() ->void:
	update_score.emit(0)
	update_difficulty.emit(1.0)


func _on_update_difficulty(value: float) -> void:
	difficultyLabel.text = difficultyText % (roundf(value*100)/100)


func _on_update_score(value: int) -> void:
	var scoreTextTranslated = scoreText % tr("SCORE")
	score = value
	scoreLabel.text = scoreTextTranslated % value


func _on_game_ui_score_changed(score: int, multiplier: float) -> void:
	update_score.emit(score)
	update_difficulty.emit(multiplier)

func lang_update(_new_locale: String):
	_on_update_score(score)
