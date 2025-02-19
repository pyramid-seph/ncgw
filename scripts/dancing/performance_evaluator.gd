class_name PlayerAttemptManager
extends Node


signal step_attempted(step: Round.Step, success: bool)
signal round_completed

# Max time the player has to input
@export_range(0.1, 1, 0.05, "or_greater") var _tolerance_sec: float = 0.5
@export_range(0.1, 1, 0.05, "or_greater") var _cooldown_sec: float = 0.5

var _curr_round: Round
var _curr_step_idx: int = -1
var _button_map: ButtonMap
var _attempt_evaulated: bool

@onready var _cooldown_timer: Timer = $CooldownTimer
@onready var _input_timer: Timer = $InputTimer


func _ready() -> void:
	set_process_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		Log.d("Ignoring an input echo: %s" % event)
		return
	
	# HACK Very dirty workaround that *may* help with the issue of the player pressing more that one button on the same frame.
	if not is_processing_input():
		Log.w("That dirty workaround was executed :(")
		return
	
	var expected_input: StringName = _get_expected_input()
	if not expected_input:
		return
	
	if _input_timer.is_stopped():
		Log.w("Input received when input timer is stopped. This should NOT happen!")
		return
	
	var curr_step: Round.Step = _curr_round.steps[_curr_step_idx]
	var success: bool = event.is_action_pressed(expected_input)
	
	if event.is_action(_button_map.down) or \
			event.is_action(_button_map.left) or \
			event.is_action(_button_map.right) or \
			event.is_action(_button_map.up):
		get_viewport().set_input_as_handled()
		
	step_attempted.emit(curr_step, success)
	set_process_input(false)
	_cooldown_timer.start(_cooldown_sec)


func start(new_round: Round, button_map: ButtonMap) -> void:
	cancel()
	_curr_round = new_round
	_button_map = button_map
	_evaluate_next_step()


func cancel() -> void:
	set_process_input(false)
	_curr_round = null
	_curr_step_idx = -1
	_cooldown_timer.stop()
	_input_timer.stop()


func _evaluate_next_step() -> void:
	set_process_input(false)
	if not _curr_round:
		Log.w("Cannot advance to next step because there is not current round.")
		return
	
	_curr_step_idx += 1
	if _curr_step_idx < _curr_round.steps.size():
		_input_timer.start()
		set_process_input(true)
	else:
		cancel()
		round_completed.emit()


func _get_expected_input() -> StringName:
	if not _curr_round or _curr_step_idx == -1 or \
			 _curr_round.steps.size() <= _curr_step_idx:
		Log.w("No _curr_round or _curr_step_idx is out of range. This should NOT happen!")
		return ""
	
	var step: Round.Step = _curr_round.steps[_curr_step_idx]
	match step:
		Round.Step.PRESS_LEFT_BTN:
			return _button_map.left
		Round.Step.PRESS_RIGHT_BTN:
			return _button_map.right
		Round.Step.PRESS_UP_BTN:
			return _button_map.up
		Round.Step.PRESS_DOWN_BTN:
			return _button_map.down
		_:
			Log.w("unknown step. %s Will not expect an input." % step)
			return ""


func _on_cooldown_timeout() -> void:
	_evaluate_next_step()


func _on_input_timer_timeout() -> void:
	if not _curr_round:
		Log.w("InputTimer timed out with no current round. This should NOT happen!")
		return
	
	var curr_step: Round.Step = _curr_round.steps[_curr_step_idx]
	step_attempted.emit(curr_step, false)
	set_process_input(false)
	_evaluate_next_step()
