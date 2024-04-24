extends StaticBody2D

@export var levelController: LevelController
@export var wallScenePath:= preload("res://Game/Sprites/AtlasCutoffs/WallSprite.tscn")

@onready var leftCollider = $LCollider
@onready var rightCollider = $RCollider
@onready var leftArea = $AreaColliders/LCollider
@onready var rightArea = $AreaColliders/RCollider

func _ready() -> void:
	create_walls()
	set_colliders()


func set_colliders():
	var leftCollisionShape = setup_collision_shape()
	var leftPosition: Vector2
	leftPosition.x = levelController.gridHelper.gridToWorld(Vector2i(-1,0)).x
	leftPosition.y = get_viewport_rect().size.y/2-levelController.gridHelper.cellSize.y/2
	leftCollider.position = leftPosition
	leftCollider.shape = leftCollisionShape
	leftArea.position = leftPosition
	leftArea.shape = leftCollisionShape
	var rightCollisionShape = setup_collision_shape()
	var rightPosition: Vector2
	rightPosition.x = levelController.gridHelper.gridToWorld(Vector2i(levelController.fieldSize.x, 0)).x
	rightPosition.y = get_viewport_rect().size.y/2-levelController.gridHelper.cellSize.y/2
	rightCollider.position = rightPosition
	rightCollider.shape = rightCollisionShape
	rightArea.position = rightPosition
	rightArea.shape = rightCollisionShape


func setup_collision_shape():
	var shape = RectangleShape2D.new()
	shape.size.x = levelController.gridHelper.cellSize.x
	shape.size.y = levelController.gridHelper.gridToWorld(Vector2i(-1,-2)).distance_to(levelController.gridHelper.gridToWorld(Vector2i(-1, levelController.fieldSize.y)))
	return shape


func create_walls():
	create_left_wall()
	create_right_wall()


func create_left_wall():
	for height in levelController.fieldSize.y+2:
		var wallTile = wallScenePath.instantiate()
		wallTile.position = levelController.gridHelper.gridToWorld(Vector2i(-1, height-2))
		add_child(wallTile)

func create_right_wall():
	for height in levelController.fieldSize.y+2:
		var wallTile = wallScenePath.instantiate()
		wallTile.position = levelController.gridHelper.gridToWorld(Vector2i(levelController.fieldSize.x, height-2))
		add_child(wallTile)
