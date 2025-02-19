class_name BtnMapWheel
extends Node2D


signal new_btn_config_shown

const BTN_FRAME_LEFT: int = 0
const BTN_FRAME_RIGHT: int = 1
const BTN_FRAME_UP: int = 2
const BTN_FRAME_DOWN: int = 3
const BTN_FRAME_UNKNOWN: int = 4

var _tween_roulette: Tween
var _tween_show_config: Tween

@onready var _btn_top_sprite: Sprite2D = $BtnTopSprite2D
@onready var _btn_bottom_sprite: Sprite2D = $BtnBottomSprite2D
@onready var _btn_left_sprite: Sprite2D = $BtnLeftSprite2D
@onready var _btn_right_sprite: Sprite2D = $BtnRightSprite2D


func show_button_map(new_button_map: ButtonMap, skip_animation: bool = false) -> void:
	if not new_button_map:
		_btn_top_sprite.frame = BTN_FRAME_UNKNOWN
		_btn_bottom_sprite.frame = BTN_FRAME_UNKNOWN
		_btn_left_sprite.frame = BTN_FRAME_UNKNOWN
		_btn_right_sprite.frame = BTN_FRAME_UNKNOWN
		new_btn_config_shown.emit.call_deferred()
		return
	
	var top_sprite_frame: int = _get_btn_texture_frame(new_button_map.up)
	var bottom_sprite_frame: int = _get_btn_texture_frame(new_button_map.down)
	var left_sprite_frame: int = _get_btn_texture_frame(new_button_map.left)
	var right_sprite_frame: int = _get_btn_texture_frame(new_button_map.right)
	
	if skip_animation:
		_btn_top_sprite.frame = top_sprite_frame
		_btn_bottom_sprite.frame = bottom_sprite_frame
		_btn_left_sprite.frame = left_sprite_frame
		_btn_right_sprite.frame = right_sprite_frame
		new_btn_config_shown.emit.call_deferred()
		return
	
	if _tween_show_config:
		_tween_show_config.kill()
	
	if _tween_roulette:
		_tween_roulette.kill()
	_tween_roulette = create_tween()
	for btn_sprite: Sprite2D in get_children():
		_tween_roulette.set_loops(10)
		_tween_roulette.parallel().tween_property(btn_sprite, "frame", \
				btn_sprite.hframes - 2, 0.2).from(0)
	_tween_roulette.finished.connect(
		func():
			if _tween_show_config:
				_tween_show_config.kill()
			_tween_show_config = create_tween()
			_tween_show_config.parallel().tween_property(_btn_top_sprite, \
					"frame", top_sprite_frame, 1.0)
			_tween_show_config.parallel().tween_property(_btn_bottom_sprite, \
					"frame", bottom_sprite_frame, 1.0)
			_tween_show_config.parallel().tween_property(_btn_left_sprite, \
					"frame", left_sprite_frame, 1.0)
			_tween_show_config.parallel().tween_property(_btn_right_sprite, \
					"frame", right_sprite_frame, 1.0)
			_tween_show_config.finished.connect(new_btn_config_shown.emit)
	)


func _get_btn_texture_frame(step: StringName) -> int:
	match step:
		&"btn_left":
			return BTN_FRAME_LEFT
		&"btn_right":
			return BTN_FRAME_RIGHT
		&"btn_up":
			return BTN_FRAME_UP
		&"btn_down":
			return BTN_FRAME_DOWN
		_:
			return BTN_FRAME_UNKNOWN
