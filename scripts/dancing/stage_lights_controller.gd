class_name StageLightsController
extends Node2D


@onready var _one_light_sprite: Sprite2D = $OneLightSprite
@onready var _total_darkness_sprite: ColorRect = $TotalDarkness


func turn_on_lights() -> void:
	_one_light_sprite.hide()
	_total_darkness_sprite.hide()


func turn_off_lights() -> void:
	_one_light_sprite.hide()
	_total_darkness_sprite.show()


func shine_light_on_player() -> void:
	_one_light_sprite.flip_h = true
	_one_light_sprite.show()
	_total_darkness_sprite.hide()


func shine_light_on_leader() -> void:
	_one_light_sprite.flip_h = false
	_one_light_sprite.show()
	_total_darkness_sprite.hide()
