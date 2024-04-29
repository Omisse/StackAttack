extends HBoxContainer

class_name MobileInputHandler

@onready var leftButton: Button = $LeftButton
@onready var rightButton: Button = $RightButton

var player: CharacterBody2D

var event:InputEventAction = InputEventAction.new()
var ourUI: GameUI

var mobileH: int = 0
var mobileV: bool = false

var leftDown = []
var rightDown = []


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if is_in_rect(event.position, leftButton.get_global_rect()):
				leftDown.append(event.index)
			elif is_in_rect(event.position, rightButton.get_global_rect()):
				rightDown.append(event.index)
		else:
			leftDown.erase(event.index)
			rightDown.erase(event.index)

func is_in_rect(samplePosition: Vector2, targetRect: Rect2):
	return targetRect.has_point(samplePosition)


func _process(delta: float) -> void:
	visible = !get_tree().paused
	if visible:
		if leftDown.size() and rightDown.size():
			player.mobileV = true
		else:
			player.mobileV = false
			if leftDown.size():
				player.mobileH = -1
			elif rightDown.size():
				player.mobileH = 1
			else:
				player.mobileH = 0

"""
func _ready() -> void:
	leftButton.button_down.connect(_on_lb_down)
	leftButton.button_down.connect(_on_any_down)
	rightButton.button_down.connect(_on_rb_down)
	rightButton.button_down.connect(_on_any_down)
	leftButton.button_up.connect(_on_lb_up)
	rightButton.button_up.connect(_on_rb_up)
	
func _on_any_down():
	if leftDown and rightDown:
		player.mobileV = true
	else:
		player.mobileV = false

func _on_lb_down():
	player.mobileH-=1
	player.mobileH = roundf(player.mobileH)


func _on_rb_down():
	player.mobileH+=1
	player.mobileH = roundf(player.mobileH)


func _on_lb_up():
	player.mobileH+=1
	player.mobileH = roundf(player.mobileH)

func _on_rb_up():
	player.mobileH-=1
	player.mobileH = roundf(player.mobileH)
"""
