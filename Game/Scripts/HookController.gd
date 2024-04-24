extends Node2D

class_name HookController

@export var amountMultiplier: float = 2
@export var amountIncrement: float = 3 ##How much the score multiplier should change to add hook for another amountMultiplier times
@export var levelController:LevelController

@onready var hookScene = load("res://Game/Scenes/Hook.tscn")

var hookAmount:int = 0

func _ready() -> void:
	levelController.score_changed.connect(_on_score_changed)
	_on_score_changed(0, levelController.speed)

func spawn_hook():
	var hook = hookScene.instantiate()
	hook.levelController = levelController
	add_child(hook)
	
func _on_score_changed(score: int, multiplier: float):
	var hookDiff: int = ceil((floor(multiplier/amountIncrement)+1)*amountMultiplier)-hookAmount
	if hookAmount < ceil((floor(multiplier/amountIncrement)+1)*amountMultiplier):
		for number in hookDiff:
			hookAmount+=1
			spawn_hook()
