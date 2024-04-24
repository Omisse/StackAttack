extends Node2D

class_name LevelController

signal restarting
signal lost
signal line_filled
signal player_hit(health: float)
signal score_changed(newScore: int, multiplier: float)

@export_group("Grid settings")
@export var fieldSize := Vector2i(13,5)
@export var gridHelper:GridHelper

@export_group("Speed related settings")
@export var speedScale: float = 1.05
@export var defaultSpeed : float = 1

@export_group("Hook spawn overrides")
@export var hookSpawnerScene: = preload("res://Game/Scenes/HookController.tscn")

@export_group("Boundaries overrides")
@export var floorScene = preload("res://Game/Scenes/Floor.tscn")
@export var wallScene = preload("res://Game/Scenes/Walls.tscn")
@export var ceilingScene = preload("res://Game/Scenes/Ceiling.tscn")

@export_group("Field overrides")
@export var playerScene = preload("res://Game/Scenes/Player.tscn")
@export var backgroundTexture = preload("res://Game/Sprites/bg.png")

@export_group("UI overrides")
@export var ingameUIScene = preload("res://UI/UIScenes/IngameUI.tscn")
@export var mainMenuScene = preload("res://UI/UIScenes/MainMenuUI.tscn")


@onready var loseSound: AudioStreamPlayer = $"/root/Audio/Lose"


var speed: float
var lineCount: int = 0
var playerHealth:= 2
var score:int = 0
var ownUINodes: Array[Node]

func _enter_tree() -> void:
	gridHelper.initialize_grid()
	speed = defaultSpeed


func _ready() -> void:
	await bootstrap()
	score_changed.emit(score, speed)

func _physics_process(delta: float) -> void:
	if lineCount >= fieldSize.x:
		line_filled.emit()
		lineCount -= fieldSize.x


func _on_iterator_timeout() -> void:
	speed *= speedScale
	score_changed.emit(score, speed)


func bootstrap():
	backgroundBootstrap()
	floorBootstrap()
	ceilingBootstrap()
	wallsBootstrap()
	playerBootstrap()
	hookControllerBootstrap()
	uiBootstrap()
	audioBootstrap()


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

func ceilingBootstrap():
	var ceiling = ceilingScene.instantiate()
	ceiling.levelController = self
	ceiling.scale *= gridHelper.cellScale
	add_child(ceiling)
	await ceiling.ready

func floorBootstrap():
	var floor = floorScene.instantiate()
	floor.levelController = self
	floor.scale *= gridHelper.cellScale
	add_child(floor)
	await floor.ready

func wallsBootstrap():
	var walls = wallScene.instantiate()
	walls.levelController = self
	walls.scale *= gridHelper.cellScale
	add_child(walls)
	await walls.ready


func backgroundBootstrap():
	var background = Sprite2D.new()
	background.texture = backgroundTexture
	background.position = get_viewport_rect().size/2-Vector2(0, gridHelper.offset.y/2)
	background.scale *= gridHelper.cellScale
	add_child(background)
	await background.ready


func playerBootstrap():
	var player = playerScene.instantiate()
	player.levelController = self
	var grid_playerPos: Vector2i = Vector2i(floori(fieldSize.x/2), fieldSize.y-1)
	player.position = gridHelper.gridToWorld(grid_playerPos)
	player.scale *= gridHelper.cellScale
	player.levelScale *= gridHelper.cellScale
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
