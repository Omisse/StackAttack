extends Node

@onready var level = $".."

var time = false

func _process(delta: float) -> void:
	if !time:
		level = get_parent()
		time = true
	var target_position = Vector2(level.get_viewport_rect().size.x/2-ProjectSettings.get_setting("display/window/size/viewport_width")/2, level.get_viewport_rect().size.y/2-ProjectSettings.get_setting("display/window/size/viewport_height")/2)
	if level.position != target_position:
		level.position = target_position
