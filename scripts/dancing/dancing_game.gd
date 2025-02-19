extends Node2D


@export var _challenge: Challenge

@onready var _leader: NpcDancer = %Leader
@onready var _player: PlayerDancer = %Player


func _ready() -> void:
	_player.steps_completed.connect(_on_player_round_completed)
	_player.step_attempted.connect(_on_player_step_attempted)
	var btn_map: ButtonMap = ButtonMap.new()
	_player.btn_map = btn_map
	_leader.steps_completed.connect(print.bind("Finished round."))
	_leader.btn_map_wheel.show_button_map(btn_map)
	await _leader.btn_map_wheel.new_btn_config_shown
	
	for i in 100:
		await get_tree().create_timer(2.0).timeout
		_leader.perform_steps(_challenge.rounds[0].steps)
		await _leader.steps_completed
		print("PLAYER TURN!")
		_player.attempt_steps(_challenge.rounds[0].steps)
		await _player.steps_completed


func _on_player_round_completed() -> void:
	print("Player round completed!")


func _on_player_step_attempted(_step: Round.Step, success: bool) -> void:
	print("CORRECT" if success else "FAIL!!!!!!!!!!!!!!")

