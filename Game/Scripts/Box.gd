extends StaticBody2D

class_name Box

signal start_move
signal destroyed(pointsAmount: int)

@export var moveScale: float = 1
@export var constantMoveSpeed: float = 50
@export var fallSpeed: float = 100
@export var maxMultiplier: float = 2
@export var levelController: LevelController
@onready var fallSound:= $"/root/Audio/BoxFall" as AudioStreamPlayer
@onready var destroySound:= $"/root/Audio/BoxDisappear" as AudioStreamPlayer

@onready var topArea = $TopBoxArea
@onready var leftArea = $LeftBoxArea
@onready var rightArea = $RightBoxArea
@onready var downArea = $DownBoxArea

@onready var downCollider = $DownBoxArea/CollisionShape2D
@onready var topCollider = $TopBoxArea/CollisionShape2D


var moveSign: float
var moving = false
var isOnGround = false
var falling = true
var moveTarget:Vector2

func _ready():
	levelController.restarting.connect(destroy)
	destroyed.connect(levelController.add_score)

func _physics_process(delta: float) -> void:
	if moving:
		var actualSign = sign(moveTarget.x - position.x)
		if actualSign != moveSign or actualSign == 0:
			position.x = moveTarget.x
			moving = false
		else:
			position.x += clampf(levelController.speed,0,maxMultiplier)*moveScale*(levelController.gridHelper.cellSize.x*actualSign)*delta
	if falling:
		position.y += clampf(levelController.speed,0,maxMultiplier)*fallSpeed*delta
	else:
		position.y = levelController.gridHelper.gridToWorld(levelController.gridHelper.worldToGrid(position)).y
	if levelController.gridHelper.worldToGrid(position).y == -1 and !falling and !moving:
		levelController.lose()
	
func push(side: int):
	if !topArea.has_overlapping_areas():
		if !moving:
			match side:
				-1:
					if !leftArea.has_overlapping_areas():
						moving = true
						moveTarget = levelController.gridHelper.gridToWorld(levelController.gridHelper.worldToGrid(position)+Vector2i(side, 0))
						start_move.emit()
				1:
					if !rightArea.has_overlapping_areas():
						moving = true
						moveTarget = levelController.gridHelper.gridToWorld(levelController.gridHelper.worldToGrid(position)+Vector2i(side, 0))
						start_move.emit()


func destroy() -> void:
	if levelController.restarting.is_connected(destroy): 
		levelController.restarting.disconnect(destroy)
	if levelController.line_filled.is_connected(destroy): 
		levelController.line_filled.disconnect(destroy)
		destroyed.emit(10)
	else:
		destroyed.emit(1)
	Audio.play_sound(destroySound)
	var topBoxes = topArea.get_overlapping_areas()
	for area in topBoxes:
		if area.get_parent().has_method("destroy"):
			area.get_parent().falling = true
	get_parent().remove_child(self)
	queue_free()

func _on_down_box_area_area_entered(area: Area2D) -> void:
	falling = false
	Audio.play_sound(fallSound)
	if levelController.gridHelper.worldToGrid(position).y >= levelController.fieldSize.y-1 and !isOnGround:
		isOnGround = true
		levelController.lineCount+=1
		levelController.line_filled.connect(destroy)


func _on_down_box_area_area_exited(area: Area2D) -> void:
	if !downArea.has_overlapping_areas():
		falling = true


func _on_start_move() -> void:
	moveSign = sign(moveTarget.x - position.x)
