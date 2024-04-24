extends HBoxContainer

class_name HealthUI

@export var healthContainer:= preload("res://UI/UIScenes/HealthContainer.tscn")##ContainerScene, textureProgressBar
@export var containerAmount: int = 2 ##amount of healthcontainers, shouldnt be less than Base Health
@export var baseHealth: float = 2 ##health amount by default
@export var healthMultiplier: float = 100 ##if we count by hearts, then 100, if by 1/2 of heart - 50 and so on.

var containers: Array

func _init() -> void:
	init()


func init() -> void:
	remove_containers()
	for container in containerAmount:
		var newHealth = healthContainer.instantiate()
		var healthNode = newHealth.get_child(0)
		healthNode.max_value = (container+1)*100
		healthNode.min_value = container*100
		add_child(newHealth)
		containers.append(healthNode)
	_on_update_health(baseHealth)


func remove_containers():
	for container in containers:
		remove_child(container.get_parent())
		container.get_parent().queue_free()
	containers.clear()


func _on_update_health(health: float) -> void:
	for container in containers:
		container.value = health*healthMultiplier
