@tool
extends Node2D


@export var offset: Vector2 = Vector2.ZERO
@export var rows: int = 6
@export var columns: int = 10
@export var cellScale: float = 1
@export var defaultResolution := Vector2(128,128)
@export var redraw := false
@onready var boxScene := preload("res://Game/Debug/DebugBox.tscn")

var boxes: Dictionary = {}
var cellSize := Vector2.ZERO

func drawGrid() -> void:
	freeGrid()
	cellSize = defaultResolution*cellScale
	for column in columns:
		for row in rows:
			var box = boxScene.instantiate() as StaticBody2D
			box.position = gridToWorld(Vector2i(column, row))
			box.scale *= cellScale
			var boxCollider = box.get_child(0)
			boxCollider.global_position = gridToWorld(worldToGrid(box.position))
			add_child(box)
			boxes[Vector2i(column,row)] = box
	

func freeGrid() -> void:
	for box in boxes:
		remove_child(boxes[box])
		boxes[box].queue_free()
	boxes = {}
	
func gridToWorld(grid_index: Vector2i) -> Vector2:
	return Vector2(grid_index.x*cellSize.x, grid_index.y*cellSize.y)+cellSize/2+offset
	
func worldToGrid(world_position: Vector2) -> Vector2i:
	return Vector2i((Vector2(world_position.x/cellSize.x,world_position.y/cellSize.y)-Vector2(offset.x/cellSize.x, offset.y/cellSize.y)).floor())

func _process(delta: float) -> void:
	if redraw:
		drawGrid()
		redraw = false
