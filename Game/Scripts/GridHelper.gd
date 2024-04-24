extends Resource

class_name GridHelper

@export_group("Position settings")
@export var offset: Vector2 = Vector2(128,256) ##decribes how far to the upper-left corner of the screen the (0,0) point will be

@export_group("Size settings")
@export var cellScale: float = 1
@export var defaultResolution := Vector2(128,128)


var cellSize := Vector2.ZERO

func _ready() -> void:
	initialize_grid()

func initialize_grid() -> void:
	cellSize = defaultResolution*cellScale

func gridToWorld(grid_index: Vector2i) -> Vector2:
	return Vector2(grid_index.x*cellSize.x, grid_index.y*cellSize.y)+cellSize/2+offset
	
func worldToGrid(world_position: Vector2) -> Vector2i:
	return Vector2i((Vector2(world_position.x/cellSize.x,world_position.y/cellSize.y)-Vector2(offset.x/cellSize.x, offset.y/cellSize.y)).floor())
