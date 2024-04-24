extends VBoxContainer

class_name SoundUI

signal update_sound(soundValue: float)

@export var loudness:= 100.0
@export var soundOn := true

@onready var slider := $VSlider
@onready var button := $TextureButton

func _ready() -> void:
	slider.visible = false
	loudness = slider.value
	soundOn = !button.button_pressed


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var _event = event as InputEventMouseMotion
		var distanceDelta = (position-get_global_mouse_position()).abs()
		if distanceDelta.x <= scale.x*size.x and distanceDelta.y <= scale.y*size.y:
			slider.visible = true
		else:
			slider.visible = false



func _on_v_slider_value_changed(value: float) -> void:
	loudness = value
	if !loudness:
		button.set_pressed_no_signal(true)
	else:
		button.set_pressed_no_signal(false)
	update_sound.emit(loudness)


func _on_texture_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		update_sound.emit(0.0)
	else:
		update_sound.emit(loudness)

