extends Node2D


@export var _challenge: Challenge

var _round_idx: int = 0

@onready var _steps_reader: StepsReader = %StepsReader
@onready var _demonstrator: AnimatedSprite2D = %Demonstrator
@onready var _step_label: Label = %StepLabel


func _ready() -> void:
	_steps_reader.round_completed.connect(_on_round_completed)
	_steps_reader.step_changed.connect(_on_round_step_changed)
	
	_step_label.text = "START!"
	await get_tree().create_timer(2.0).timeout
	_steps_reader.start_round(_challenge.rounds[_round_idx])


func get_animation(step: Round.Step) -> StringName:
	match step:
		Round.Step.WAIT:
			return &"wait"
		Round.Step.PRESS_LEFT_BTN:
			return &"press_left"
		Round.Step.PRESS_RIGHT_BTN:
			return &"press_right"
		Round.Step.PRESS_UP_BTN:
			return &"press_up"
		Round.Step.PRESS_DOWN_BTN:
			return &"press_down"
		_:
			Log.w("unknown step. %s Will play WAIT animation instead." % step)
			return &"wait"


func get_label(action: Round.Step) -> String:
	match action:
		Round.Step.WAIT: return "[ * ]"
		Round.Step.PRESS_LEFT_BTN: return "[ < ]"
		Round.Step.PRESS_RIGHT_BTN: return "[ > ]"
		Round.Step.PRESS_UP_BTN: return "[ ^ ]"
		Round.Step.PRESS_DOWN_BTN: return "[  v  ]"
		_: return "[ ? ]: " + str(action)
	

func _on_round_step_changed(step: Round.Step) -> void:
	var animation: StringName = get_animation(step)
	_demonstrator.play(animation)
	_demonstrator.set_frame_and_progress(0, 0.0)
	_step_label.text = str(_round_idx) + ": " + str(_steps_reader._step_idx) + \
			 ": " + get_label(step)


func _on_round_completed() -> void:
	_step_label.text = str(_round_idx) + ": " + "COMPLETE!"
	_demonstrator.play(&"wait")
	await get_tree().create_timer(4).timeout
	_round_idx = wrapi(_round_idx + 1, 0, _challenge.rounds.size())
	_steps_reader.start_round(_challenge.rounds[_round_idx])
