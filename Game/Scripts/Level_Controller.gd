extends Node2D

class_name LevelController

signal restarting
signal lost
signal line_filled
signal player_hit(health: float)
signal score_changed(newScore: int, multiplier: float)

@export_group("Grid")
@export var gameFieldStart: Vector2i
@export var gameFieldEnd: Vector2i

@export_group("Speed related settings")
@export var speedScale: float = 1.05
@export var defaultSpeed : float = 1

@export_group("Hook spawn overrides")
@export var hookSpawnerScene: = preload("res://Game/Scenes/HookController.tscn")

@export_group("Field overrides")
@export var playerScene = preload("res://Game/Scenes/Player.tscn")
@export var areaCollider = preload("res://Game/Scenes/AreaCollider.tscn")

@export_group("UI overrides")
@export var ingameUIScene = preload("res://UI/UIScenes/IngameUI.tscn")
@export var mainMenuScene = preload("res://UI/UIScenes/MainMenuUI.tscn")


@onready var loseSound: AudioStreamPlayer = $"/root/Audio/Lose"
@onready var grid = $TileMap as TileMap
@onready var iterator = $Iterator

var speed: float
var lineCount: int = 0
var fieldSize: Vector2i
var playerHealth:= 2
var score:int = 0
var ownUINodes: Array[Node]

func _enter_tree() -> void:
	speed = defaultSpeed


func _ready() -> void:
	iterator.timeout.connect(_on_iterator_timeout)
	await bootstrap()
	fieldSize.x = gameFieldEnd.x - gameFieldStart.x + 1
	fieldSize.y = gameFieldEnd.y - gameFieldStart.y + 1
	score_changed.emit(score, speed)

func _physics_process(delta: float) -> void:
	position = $ColorRect.position
	if lineCount >= fieldSize.x:
		line_filled.emit()
		lineCount -= fieldSize.x


func _on_iterator_timeout() -> void:
	speed *= speedScale
	score_changed.emit(score, speed)


func bootstrap():
	gridAreaCreate()
	playerBootstrap()
	hookControllerBootstrap()
	uiBootstrap()
	audioBootstrap()


func gridAreaCreate():
	for layer in 2:
		var usedCells = grid.get_used_cells(layer) as Array[Vector2i]
		for cell in usedCells:
			var newArea = areaCollider.instantiate()
			newArea.position = grid.map_to_local(cell)
			var colliderShape = newArea.get_child(0).shape as RectangleShape2D
			colliderShape.size = grid.tile_set.tile_size
			add_child(newArea)
		


func audioBootstrap():
	score_changed.connect(Audio._on_score_changed)


func uiBootstrap():
	var ingameUI = ingameUIScene.instantiate()
	for childNode in ingameUI.get_children():
		childNode.levelController = self
		childNode.request_ready()
	add_child.call_deferred(ingameUI)
	await ingameUI.ready


func hookControllerBootstrap():
	var hookController = hookSpawnerScene.instantiate() as HookController
	hookController.levelController = self
	hookController.hooksAmount = 1
	add_child.call_deferred(hookController)
	await hookController.ready


func playerBootstrap():
	var player = playerScene.instantiate()
	player.levelController = self
	var grid_playerPos: Vector2i = Vector2i(gameFieldStart.x+roundi((gameFieldEnd.x-gameFieldStart.x)/2),gameFieldEnd.y-1)
	player.position = grid.map_to_local(grid_playerPos)
	if player.has_signal("hit"):
		player.hit.connect(_on_player_hit)
	add_child(player)
	await player.ready


func lose():
	Audio.play_sound(loseSound)
	lost.emit()


func restart():
	restarting.emit()
	speed = defaultSpeed
	lineCount = 0
	score = 0
	_on_player_hit(2)
	score_changed.emit(score, speed)
	
func _on_player_hit(health):
	playerHealth = health
	player_hit.emit(playerHealth)

func add_score(amount:int):
	score+=amount*speed
	score_changed.emit(score, speed)
	
func _on_exit():
	get_tree().change_scene_to_packed(mainMenuScene)
