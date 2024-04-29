extends HBoxContainer

class_name HealthUI

@export var containerAmount: int = 2 ##amount of healthcontainers, shouldnt be less than Base Health
@export var baseHealth: float = 2 ##health amount by default
@export var healthMultiplier: float = 100 ##if we count by hearts, then 100, if by 1/2 of heart - 50 and so on.

var containers: Array

func _ready():
	var childCount: int = 0
	for childNode in get_children():
		var healthNode = childNode as TextureProgressBar
		healthNode.max_value = (childCount+1)*100
		healthNode.min_value = childCount*100
		childCount+=1
		containers.append(healthNode)
		_on_update_health(baseHealth)


func _on_update_health(health: float) -> void:
	for container in containers:
		container.value = health*healthMultiplier
