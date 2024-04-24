extends StaticBody2D


@export var levelController: LevelController
@export var ceilingLevel: int = -2
@export var textureOverride: = preload("res://Game/Sprites/AtlasCutoffs/CeilingTexture.tres")
@export var spriteRescale:= Vector2(0.8, 0.8)

@onready var collider = $CollisionShape2D
@onready var area = $Area2D/CollisionShape2D

func _ready() -> void:
	var gridWidth = levelController.fieldSize.x+2
	var canvasGroup = CanvasGroup.new()
	add_child(canvasGroup)
	for tile in gridWidth:
		var sprite = Sprite2D.new()
		sprite.texture = textureOverride
		sprite.position = levelController.gridHelper.gridToWorld(Vector2i(tile-1, ceilingLevel))
		sprite.scale.x = spriteRescale.x
		sprite.scale.y = spriteRescale.y
		canvasGroup.add_child(sprite)
	collider.shape.size.x = get_viewport_rect().size.x
	collider.shape.size.y = levelController.gridHelper.cellSize.y
	collider.position.y = levelController.gridHelper.gridToWorld(Vector2i(0,ceilingLevel)).y
	collider.position.x = levelController.gridHelper.gridToWorld(Vector2i(roundi(levelController.fieldSize.x/2.0),0)).x-levelController.gridHelper.cellSize.x
	area.shape = collider.shape
	area.position = collider.position
