@tool

extends Node

class_name CodeRunner

@export var needReady: bool

var a = [1,2,3,4,5,6,7,8]

func ready_reloader():
	if needReady:
		needReady = false
		_ready()


##write here your own functions to run once
func _ready() -> void:
	#random_limits(1000, a)
	pass


##write here your own functions to run it in the editor every frame
func _process(delta: float) -> void:
	ready_reloader()


func random_limits(stackSize: int, array: Array):
	var randArray: Array
	randArray.clear()
	for i in stackSize:
		randArray.append(randi_range(0, array.size()-1))
	print_debug("Max: ", randArray.max())
	print_debug("Min: ", randArray.min())
