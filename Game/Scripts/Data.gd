extends Node

@export var scorePath = "user://userdata.dat"

func save_score(new_score: int):
	var scoreFile = FileAccess.open(scorePath, FileAccess.WRITE)
	if scoreFile:
		scoreFile.store_var(new_score)
		scoreFile.close()
		print("score saved ", new_score)
	else:
		print("data saving error, file is null")


func load_score() -> int:
	var score: int = 0
	if FileAccess.file_exists(scorePath):
		var scoreFile = FileAccess.open(scorePath,FileAccess.READ)
		if scoreFile:
			score = scoreFile.get_var()
			scoreFile.close()
		else:
			print("data saving error, file is null")
	else:
		save_score(0)
	print("loaded score ", score)
	return score
