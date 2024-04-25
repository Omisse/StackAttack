extends Node

signal gotPlayerEntryCallback
signal scoreSyncDone

var highScore: int = 0
var isInitialised: bool = false

func _ready() -> void:
	Yandex._getLeaderboardPlayerEntry_then.connect(_on_lb_get_player_entry_result)
	Yandex._getLeaderboardPlayerEntry_catch.connect(_on_lb_get_player_entry_result)

func initPlayerScore():
	Yandex.getLeaderboardPlayerEntry('leaderboard')
	await gotPlayerEntryCallback
	isInitialised = true
	scoreSyncDone.emit()

func getPlayerScore():
	return highScore

func _on_lb_get_player_entry_result(args):
	if typeof(args) != TYPE_STRING:
		highScore = args['score']
	gotPlayerEntryCallback.emit()

func setPlayerScore(newScore: int):
	highScore = newScore
	Yandex.setLeaderboardScore('leaderboard', highScore)
