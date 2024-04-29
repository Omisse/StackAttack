extends Control

class_name MenuUI

signal update_language(newLocale: String)
signal update_sound(newVolumeLinear: float)

@export var playScenePath: String

@onready var playButton: Button = %PlayButton
@onready var languageButton: Button = %LanguageButton
@onready var soundToggler: TextureButton = %MuteButton
@onready var soundSlider: Slider = %Volume

func _ready() -> void:
	soundSlider.value = Audio.masterVolume
	
	playButton.pressed.connect(_on_play_pressed)
	
	languageButton.pressed.connect(_on_lang_pressed)
	init_lang_icon()
	
	soundToggler.toggled.connect(_on_sound_toggled)
	soundSlider.value_changed.connect(_on_volume_changed)
	update_sound.connect(Audio._on_volume_changed)
	
	playButton.grab_focus()
	if !Yandex.is_initGame:
		Yandex.initGame()
		await Yandex._initGame
		Yandex.on_ready()
	
	if !ScoreStorage.isInitialised:
		ScoreStorage.initPlayerScore()
		await ScoreStorage.gotPlayerEntryCallback


func _on_play_pressed():
	var nextScene = load(playScenePath)
	update_sound.disconnect(Audio._on_volume_changed)
	get_tree().paused = false
	get_tree().change_scene_to_packed(nextScene)

func init_lang_icon() -> void:
	if TranslationServer.get_locale() == "en":
		languageButton.icon = load("res://UI/UIResources/AtlasCutoffs/RuFlagIcon.tres")
	else:
		languageButton.icon = load("res://UI/UIResources/AtlasCutoffs/EnFlagIcon.tres")


func _on_lang_pressed():
	if TranslationServer.get_locale() == "ru":
		TranslationServer.set_locale("en")
		languageButton.icon = load("res://UI/UIResources/AtlasCutoffs/RuFlagIcon.tres")
		update_language.emit("en")
	else:
		TranslationServer.set_locale("ru")
		languageButton.icon = load("res://UI/UIResources/AtlasCutoffs/EnFlagIcon.tres")
		update_language.emit("ru")


func _on_sound_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		_on_volume_changed(0.0)
	else:
		_on_volume_changed(soundSlider.value)
	
func _on_volume_changed(value: float) -> void:
	if !value:
		soundToggler.set_pressed_no_signal(false)
	else:
		soundToggler.set_pressed_no_signal(true)
	update_sound.emit(value)
