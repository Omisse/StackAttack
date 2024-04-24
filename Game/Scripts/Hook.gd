extends Node2D

class_name Hook

signal field_left
signal field_entered
signal item_dropped(item: ItemResource)

@onready var itemSprite = $ItemSprite as Sprite2D

var levelController: LevelController

var speed: float
var item: ItemResource
var dropPosition: Vector2

var startPosition: Vector2
var endPosition: Vector2


func _ready():
	itemSprite.texture = load(item.texturePath)
	scale *= levelController.gridHelper.cellScale
	position = startPosition
	field_left.connect(destroy)


var dropped: bool = false
var done: bool = false
var moved: bool = false

func _process(delta: float) -> void:
	var moveSign = signf(endPosition.x-startPosition.x)
	var dropSign = signf(dropPosition.x-position.x)
	var endSign = signf(endPosition.x-position.x)
	
	position.x += moveSign*speed*delta
	
	if not dropped and dropSign != moveSign:
		dropped = true
		drop_item()
		item_dropped.emit(item)
	if not done and endSign != moveSign:
		done = true
		field_left.emit()
	if not moved and absf(position.x-startPosition.x) >= levelController.gridHelper.cellSize.x:
		moved = true
		field_entered.emit()


func drop_item():
	itemSprite.hide()
	var itemNode = load(item.scenePath).instantiate()
	itemNode.levelController = levelController
	itemNode.position = dropPosition
	itemNode.scale *= levelController.gridHelper.cellScale
	levelController.add_child(itemNode)

func destroy():
	get_parent().remove_child(self)
	queue_free()
