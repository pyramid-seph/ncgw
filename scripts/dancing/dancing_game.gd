extends Node2D


@export var _challenge: Challenge

@onready var _leader: NpcDancer = %Leader


func _ready() -> void:
	_leader.steps_completed.connect(print.bind("Finished round."))
	_leader.btn_map_wheel.show_button_map(ButtonMap.new())
	await _leader.btn_map_wheel.new_btn_config_shown
	await get_tree().create_timer(2.0).timeout
	_leader.perform_steps(_challenge.rounds[2].steps)
