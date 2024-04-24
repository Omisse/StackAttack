extends Control

class_name PauseUI

signal update_language(newLanguage: String)
signal update_sound(value: float)
signal exit_pressed

@export var levelController: LevelController

@onready var ResumeButton: Button = $MarginContainer/MarginContainer/MenuLayoutContainer/ResumeButton
@onready var RestartButton: Button = $MarginContainer/MarginContainer/MenuLayoutContainer/RestartButton
@onready var ExitButton: Button = $MarginContainer/MarginContainer/MenuLayoutContainer/ExitButton
@onready var LanguageButton: Button = $MarginContainer/MarginContainer/MenuLayoutContainer/SettingsContainer/LanguageButton
@onready var SoundButton: TextureButton = $MarginContainer/MarginContainer/MenuLayoutContainer/SettingsContainer/SoundContainer/MuteButton
@onready var VolumeSlider: Slider = $MarginContainer/MarginContainer/MenuLayoutContainer/SettingsContainer/SoundContainer/Volume


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	VolumeSlider.value = Audio.masterVolume
	ResumeButton.pressed.connect(_on_resume_pressed)
	RestartButton.pressed.connect(_on_restart_pressed)
	ExitButton.pressed.connect(_on_exit_pressed)
	ExitButton.pressed.connect(levelController._on_exit)
	LanguageButton.pressed.connect(_on_lang_pressed)
	SoundButton.toggled.connect(_on_sound_toggled)
	VolumeSlider.value_changed.connect(_on_volume_changed)
	update_sound.connect(Audio._on_volume_changed)


func _on_resume_pressed():
	visible = !visible
	get_tree().paused = visible


func _on_exit_pressed():
	update_sound.disconnect(Audio._on_volume_changed)
	exit_pressed.emit()


func _on_restart_pressed():
	levelController.restart()
	_on_resume_pressed()


func _on_lang_pressed():
	if TranslationServer.get_locale() == "ru":
		TranslationServer.set_locale("en")
		LanguageButton.icon = load("res://UI/UIResources/AtlasCutoffs/EnFlagIcon.tres")
		update_language.emit("en")
	else:
		TranslationServer.set_locale("ru")
		LanguageButton.icon = load("res://UI/UIResources/AtlasCutoffs/RuFlagIcon.tres")
		update_language.emit("ru")


func _on_sound_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		_on_volume_changed(0.0)
	else:
		_on_volume_changed(VolumeSlider.value)
	
func _on_volume_changed(value: float) -> void:
	if !value:
		SoundButton.set_pressed_no_signal(false)
	else:
		SoundButton.set_pressed_no_signal(true)
	update_sound.emit(value)
