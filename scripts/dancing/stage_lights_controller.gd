class_name StageLightsController
extends Node2D

const SFX_SWITCH_OFF_LIGHT_ALL = preload("res://assets/audio/sfx/sfx_switch_off_lights_all.wav")
const SFX_SWITCH_ON_LIGHT_ALL = preload("res://assets/audio/sfx/sfx_switch_on_light_all.wav")
const SFX_SWITCH_ON_LIGHT_SPOT = preload("res://assets/audio/sfx/sfx_switch_on_light_spot.wav")

@onready var _one_light_sprite: Sprite2D = $OneLightSprite
@onready var _total_darkness_sprite: ColorRect = $TotalDarkness


func turn_on_lights(skip_sound: bool = false) -> void:
	if not skip_sound:
		SoundManager.play_sound(SFX_SWITCH_ON_LIGHT_ALL)
	_one_light_sprite.hide()
	_total_darkness_sprite.hide()


func turn_off_lights(skip_sound: bool = false) -> void:
	if not skip_sound:
		SoundManager.play_sound(SFX_SWITCH_OFF_LIGHT_ALL)
	_one_light_sprite.hide()
	_total_darkness_sprite.show()


func shine_light_on_player(skip_sound: bool = false) -> void:
	if not skip_sound:
		SoundManager.play_sound(SFX_SWITCH_ON_LIGHT_SPOT)
	_one_light_sprite.flip_h = true
	_one_light_sprite.show()
	_total_darkness_sprite.hide()


func shine_light_on_leader(skip_sound: bool = false) -> void:
	if not skip_sound:
		SoundManager.play_sound(SFX_SWITCH_ON_LIGHT_SPOT)
	_one_light_sprite.flip_h = false
	_one_light_sprite.show()
	_total_darkness_sprite.hide()
