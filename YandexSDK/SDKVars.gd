extends Node

signal gotPlayerEntryCallback

var lbHighscore: int = 0
var highScore: int = 0
var isInitialised: bool = false

func _ready() -> void:
	#if FileAccess.file_exists()
	Yandex._getLeaderboardPlayerEntry_then.connect(_on_lb_get_player_entry_result)
	Yandex._getLeaderboardPlayerEntry_catch.connect(_on_lb_get_player_entry_result)

func initPlayerScore():
	print_debug("score init started")
	var savedScore: int = SavedData.load_score()
	get_leaderboard_score()
	print_debug("gotLeaderboard")
	highScore = max(lbHighscore, savedScore)
	print_debug("highscore init: ", highScore)
	isInitialised = true

func get_leaderboard_score():
	if Yandex.js_ysdk != null:
		Yandex.getLeaderboardPlayerEntry('leaderboard')
		await gotPlayerEntryCallback
	return lbHighscore

func getPlayerScore():
	return highScore

func _on_lb_get_player_entry_result(args):
	if args is Dictionary:
		lbHighscore = args['score']
	gotPlayerEntryCallback.emit()

func setPlayerScore(newScore: int):
	highScore = newScore
	SavedData.save_score(highScore)
	Yandex.setLeaderboardScore('leaderboard', highScore)
