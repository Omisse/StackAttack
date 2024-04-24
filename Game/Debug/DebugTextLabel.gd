extends Control

@onready var textContainer = $RichTextLabel
@export var node: Node

func _process(delta: float) -> void:
	textContainer.text = var_to_str(node.boxCollection.size())
