extends StaticBody2D

@export var levelController: LevelController
@export var textureOverride:= preload("res://Game/Sprites/AtlasCutoffs/FloorTexture.tres")

@onready var floorCollider = $CollisionShape2D
@onready var floorArea = $FloorArea/FloorAreaCollider

func _ready() -> void:
	var floorWidth = levelController.fieldSize.x+2
	var canvasGroup = CanvasGroup.new()
	add_child(canvasGroup)
	for floorLevel in 2:
		for floorTile in floorWidth:
			var sprite = Sprite2D.new()
			sprite.texture = textureOverride
			sprite.position = levelController.gridHelper.gridToWorld(Vector2i(floorTile-1, levelController.fieldSize.y+floorLevel))
			if floorLevel:
				sprite.flip_v = true
			canvasGroup.add_child(sprite)
	floorCollider.shape.size.x = get_viewport_rect().size.x
	floorCollider.shape.size.y = levelController.gridHelper.cellSize.y
	floorCollider.position.y = levelController.gridHelper.gridToWorld(Vector2i(0,levelController.fieldSize.y)).y
	floorCollider.position.x = levelController.gridHelper.gridToWorld(Vector2i(roundi(levelController.fieldSize.x/2.0),0)).x-levelController.gridHelper.cellSize.x
	floorArea.shape = floorCollider.shape
	floorArea.position = floorCollider.position
