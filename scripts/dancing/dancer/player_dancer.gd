class_name PlayerDancer
extends Sprite2D


signal step_attempted(step: Round.Step, success: bool)
signal steps_completed
signal bowed


@export_group("Debug", "_debug")
@export var _debug_show_btn_mapping: bool = true:
	set(value):
		_debug_show_btn_mapping = value
		_on_btn_map_set()
	get:
		return OS.is_debug_build() and _debug_show_btn_mapping

var btn_map: ButtonMap:
	set(value):
		btn_map = value
		_on_btn_map_set()

var _steps: Array[Round.Step]
var _step_idx: int = -1
var _can_attempt_step: bool

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _btn_map_wheel: BtnMapWheel = $BtnMapWheel


func _ready() -> void:
	_on_btn_map_set()
	var animation_length: float = _animation_player.get_animation(&"idle").length
	_animation_player.play(&"idle")
	_animation_player.seek(randf_range(0.0, animation_length))


func _unhandled_input(event: InputEvent) -> void:
	if not _can_attempt_step:
		return
	
	if event.is_echo():
		var key_event := event as InputEventKey
		Log.d("Ignoring an input echo: %s" % key_event.as_text_key_label())
		return
	
	if event.is_action_pressed(btn_map.down) or \
			event.is_action_pressed(btn_map.left) or \
			event.is_action_pressed(btn_map.right) or \
			event.is_action_pressed(btn_map.up):
		get_viewport().set_input_as_handled()
	else:
		return
	
	_can_attempt_step = false
	
	var curr_step: Round.Step = _steps[_step_idx]
	var expected_input: StringName = _get_expected_input(curr_step)
	if not expected_input:
		Log.w("Unknown expected input. Canceling dance.")
		cancel()
		steps_completed.emit()
		return
	
	var success: bool = event.is_action_pressed(expected_input)
	if success:
		var dance_anim: String = _get_dance_move_anim(curr_step)
		if dance_anim:
			_animation_player.play(dance_anim)
		else:
			Log.w("Unknown dance move. Playing error anim regardless of result.")
			_animation_player.play(&"step_error")
	else:
		_animation_player.play(&"step_error")
	
	step_attempted.emit(curr_step, success)


func attempt_steps(new_steps: Array[Round.Step]) -> void:
	_steps = new_steps
	_attempt_next_step()


func cancel() -> void:
	_animation_player.play(&"idle")
	_can_attempt_step = false
	_step_idx = -1


func is_dancing() -> bool:
	return _step_idx > -1


func bow() -> void:
	if not is_dancing():
		_animation_player.play(&"bow")


func _attempt_next_step() -> void:
	_step_idx += 1
	if not _steps.is_empty() and _step_idx < _steps.size():
		_can_attempt_step = true
	else:
		cancel()
		steps_completed.emit()


func _get_expected_input(step: Round.Step) -> StringName:
	match step:
		Round.Step.PRESS_LEFT_BTN:
			return btn_map.left
		Round.Step.PRESS_RIGHT_BTN:
			return btn_map.right
		Round.Step.PRESS_UP_BTN:
			return btn_map.up
		Round.Step.PRESS_DOWN_BTN:
			return btn_map.down
		_:
			return ""


func _get_dance_move_anim(step: Round.Step) -> String:
	match step:
		Round.Step.PRESS_LEFT_BTN:
			return "step_left"
		Round.Step.PRESS_RIGHT_BTN:
			return "step_right"
		Round.Step.PRESS_UP_BTN:
			return "step_up"
		Round.Step.PRESS_DOWN_BTN:
			return "step_down"
		_:
			return ""


func _on_btn_map_set() -> void:
	if not is_node_ready():
		return
	
	if btn_map and _debug_show_btn_mapping:
		_btn_map_wheel.show()
		_btn_map_wheel.show_button_map(btn_map, true)
	else:
		_btn_map_wheel.hide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"step_left" or \
			anim_name == &"step_right" or \
			anim_name == &"step_up" or \
			anim_name == &"step_down" or \
			anim_name == &"step_error":
		_attempt_next_step ()
	elif anim_name == &"bow":
		_animation_player.play(&"idle")
		bowed.emit()
