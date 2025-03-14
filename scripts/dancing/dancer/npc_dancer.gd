class_name NpcDancer
extends Sprite2D

signal step_changed(step: Round.Step)
signal steps_completed
signal bowed


var _steps: Array[Round.Step]
var _step_idx: int = -1

@onready var btn_map_wheel: BtnMapWheel = $BtnMapWheel
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var animation_length: float = _animation_player.get_animation(&"idle").length
	_animation_player.play(&"idle")
	_animation_player.seek(randf_range(0.0, animation_length))


func perform_steps(steps: Array[Round.Step]) -> void:
	_steps = steps
	_stop_performance()
	_advance_to_next_step()


func is_dancing() -> bool:
	return _step_idx > -1


func bow() -> void:
	if not is_dancing():
		_animation_player.play(&"bow")


func _stop_performance() -> void:
	_animation_player.play(&"idle")
	_step_idx = -1


func _advance_to_next_step() -> void:
	_step_idx += 1
	if not _steps.is_empty() and _step_idx < _steps.size():
		var new_step: Round.Step = _steps[_step_idx]
		step_changed.emit(new_step)
		var next_anim: String = _get_dance_move_anim(new_step)
		if next_anim:
			_animation_player.play(next_anim)
		else:
			Log.w("unknown step. Performance will complete NOW.")
		return
	
	steps_completed.emit()
	_stop_performance()


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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"step_left" or \
			anim_name == &"step_right" or \
			anim_name == &"step_up" or \
			anim_name == &"step_down":
		if not _steps.is_empty() and _step_idx + 1 < _steps.size():
			await create_tween().tween_interval(0.2).finished
		_advance_to_next_step()
	elif anim_name == &"bow":
		_animation_player.play(&"idle")
		bowed.emit()
