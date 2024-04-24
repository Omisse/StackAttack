extends Node2D

signal state_changed

@export var idleTime: float = 5
@export var items: Array[ItemResource]

@onready var levelController: LevelController
@onready var timer = $Timer
@onready var itemSprite = $ItemSprite
@onready var area = $Area2D

var grid: GridHelper

var side:int
var speed: float = 100
var item
var target_position: Vector2

var zeroBorder: Vector2
var endBorder: Vector2

enum States{
	Idle,
	Dropping,
	Returning,
}

var _state :int

var waiting = false

func _ready():
	initialize()


func _process(delta: float) -> void:
	match _state:
		States.Idle:
			if !waiting:
				idle()
		States.Dropping:
			move(delta)
		States.Returning:
			move(delta)


func update_state(newState: int):
	_state = newState
	state_changed.emit()


func initialize():
	grid = levelController.gridHelper
	zeroBorder = grid.gridToWorld(Vector2i(-2,-1))
	endBorder = grid.gridToWorld(Vector2i(levelController.fieldSize.x+1, -1))
	scale *= grid.cellScale
	position = zeroBorder
	_state = States.Idle
	items = normalizeChances(items)
	for itemRes in items:
		load(itemRes.scenePath)


func idle():
	waiting = true
	match get_closest_border(position):
		zeroBorder:
			side = 1
		endBorder:
			side = -1
	item = roll_item(items)
	itemSprite.texture = load(item.texturePath)
	itemSprite.show()
	target_position = roll_drop_point(levelController.fieldSize)
	timer.start(randfn(idleTime/levelController.speed, idleTime/(levelController.speed*2)))
	await (timer.timeout)
	await update_state(States.Dropping)
	waiting = false


func move(delta: float):
	if sign(target_position.x-position.x) != side and _state == States.Dropping:
		drop_item(target_position)
	elif is_inside_field(position):
		position.x += side*speed*levelController.speed*delta
	else:
		position = get_closest_border(position)
		update_state(States.Idle)


func drop_item(hookPosition: Vector2):
	update_state(States.Returning)
	itemSprite.hide()
	var itemNode = load(item.scenePath).instantiate()
	itemNode.levelController = levelController
	itemNode.position = grid.gridToWorld(grid.worldToGrid(hookPosition))
	itemNode.scale *= levelController.gridHelper.cellScale
	levelController.add_child(itemNode)


func is_inside_field(actualPosition: Vector2) -> bool:
	if actualPosition.x>=zeroBorder.x and actualPosition.x <= endBorder.x:
		return true
	else:
		return false


func get_closest_border(actualPosition: Vector2):
	var distanceToZero = (actualPosition-zeroBorder).length_squared()
	var distanceToEnd = (endBorder-actualPosition).length_squared()
	if distanceToZero < distanceToEnd:
		return zeroBorder
	else:
		return endBorder


func roll_item(itemArray:Array[ItemResource]) -> ItemResource:
	var diceRoll:float = randf_range(0,1)
	var itemSum:float = 0
	for itemRes in itemArray:
		itemSum+=itemRes.rollWeight
		if diceRoll <= itemSum:
			return itemRes
	return null


func roll_drop_point(gridFieldSize: Vector2i) -> Vector2:
	return grid.gridToWorld(Vector2i(randi_range(0,gridFieldSize.x-1),grid.worldToGrid(endBorder).y))

@warning_ignore("unassigned_variable")
func normalizeChances(itemsArray:Array[ItemResource])-> Array[ItemResource]:
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
