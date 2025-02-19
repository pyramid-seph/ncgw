class_name StepsReader
extends Node


signal step_changed(step: Round.Step)
signal round_completed


@export var time_per_step: float = 1.0

var _curr_round: Round
var _timer: Timer
var _step_idx: int


func _ready() -> void:
	if not _timer:
		_timer = Timer.new()
		_timer.wait_time = time_per_step
		_timer.one_shot = true
		_timer.timeout.connect(_advance_to_next_step)
		add_child(_timer)


func start_round(new_round: Round) -> void:
	stop_round()
	_curr_round = new_round
	_advance_to_next_step()


func stop_round() -> void:
	_timer.stop()
	_curr_round = null
	_step_idx = -1


func _advance_to_next_step() -> void:
	_step_idx += 1
	if _curr_round and _step_idx < _curr_round.steps.size():
		var new_step: Round.Step = _curr_round.steps[_step_idx]
		step_changed.emit(new_step)
		_timer.start(time_per_step)
	else:
		round_completed.emit()
		stop_round()
