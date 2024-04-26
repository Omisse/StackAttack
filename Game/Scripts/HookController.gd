extends Node2D

class_name HookController

signal round_done(hookAmount: int)


@export var hookAdded: int = 1 ##how much hooks will be added to the scene on each tick
@export var addTicks: float = 1 ##basically floor(speed/addTicks) = add new hookAdded hooks amount

@export_category("One hook settings")
@export var items: Array[ItemResource] ##array of items for dropping
@export var hookMoveSpeed: float = 300 ##movespeed for a newly instantiated hook on 1.00x speed
@export var hookGridOffset:= Vector2i(0,0) ##offset for all hooks in grid coordinates
@export var hookScene = preload("res://Game/Scenes/Hook.tscn")

var levelController:LevelController

var itemsNormalized: Array[ItemResource]

var hooksAmount: int
var hooksMax: int
var hooksDone: int
var hooksToAdd: int

var borderPositions: Array[Vector2]
var positions: Array[Vector2]
var freePositions: Array[Vector2]


func _ready() -> void:
	items_init()
	positions_init()
	events_init()
	round_done.emit(0)

#region onready
func items_init():
	itemsNormalized = normalize_chances(items) as Array[ItemResource]
	for item in itemsNormalized:
		load(item.scenePath)


func positions_init():
	hooksMax = levelController.fieldSize.x-1
	var height: float = levelController.grid.map_to_local(Vector2i(0,levelController.gameFieldStart.y+hookGridOffset.y)).y
	borderPositions.append(Vector2(levelController.grid.map_to_local(Vector2i(levelController.gameFieldStart.x-2, 0)).x, height))
	borderPositions.append(Vector2(levelController.grid.map_to_local(Vector2i(levelController.gameFieldEnd.x+2, 0)).x, height))
	var grid_ceilingPositions = levelController.grid.get_used_cells(1)
	grid_ceilingPositions = grid_ceilingPositions.filter(ceiling_filter)
	for pos in grid_ceilingPositions:
		positions.append(levelController.grid.map_to_local(pos))
	freePositions = positions.duplicate()

func ceiling_filter(pos: Vector2i):
	return (pos.y == levelController.gameFieldStart.y-1 and pos.x >= levelController.gameFieldStart.x and pos.x <= levelController.gameFieldEnd.x)


func events_init():
	levelController.score_changed.connect(_on_score_changed)
	round_done.connect(_on_round_done)


#endregion

#region eventHandlers


func _on_round_done(_hooks: int):
	freePositions = positions.duplicate()
	hooksAmount += hooksToAdd
	for i in hooksAmount:
		var hook = spawn_hook()
		await hook.field_entered

func _on_hook_field_left():
	hooksDone+=1
	if hooksDone >= hooksAmount:
		round_done.emit(hooksDone)
		hooksDone = 0


func _on_score_changed(_newScore: int, multiplier: float):
	var newAmount = roundi(multiplier/addTicks)*hookAdded
	if newAmount > hooksMax:
		newAmount = hooksMax
	hooksToAdd = newAmount-hooksAmount

#endregion

#region Items


func normalize_chances(itemsArray:Array[ItemResource]) -> Array[ItemResource]:
	var normalizedArray:Array[ItemResource]
	normalizedArray.clear()
	var sum:float = 0
	for resource in itemsArray:
		sum+=resource.rollWeight
	if sum != 0:
		for resource in itemsArray:
			var newResource = ItemResource.new()
			newResource.name = resource.name
			newResource.rollWeight = resource.rollWeight/sum
			newResource.scenePath = resource.scenePath
			newResource.texturePath = resource.texturePath
			normalizedArray.append(newResource)
	return normalizedArray

func roll_item(itemArray:Array[ItemResource]) -> ItemResource:
	var diceRoll:float = randf_range(0,1)
	var itemSum:float = 0
	for itemRes in itemArray:
		itemSum+=itemRes.rollWeight
		if diceRoll <= itemSum:
			return itemRes
	return null


#endregion

#region Hook


func spawn_hook() -> Node:
	var newHook = hookScene.instantiate() as Hook
	
	newHook.dropPosition = roll_position()
	freePositions.erase(newHook.dropPosition)
	
	newHook.item = roll_item(itemsNormalized) as ItemResource
	newHook.speed = hookMoveSpeed+hookMoveSpeed*levelController.speed/10
	newHook.levelController = levelController
	
	
	var borderBool = randi_range(0,1)
	newHook.startPosition = borderPositions[borderBool]
	newHook.endPosition = borderPositions[absi(borderBool-1)]
	
	newHook.field_left.connect(_on_hook_field_left)
	
	add_child(newHook)
	
	return newHook


func roll_position()->Vector2:
	var rollSize = freePositions.size()
	var posIndex = randi_range(0, freePositions.size()-1)
	return freePositions[posIndex]


#endregion
