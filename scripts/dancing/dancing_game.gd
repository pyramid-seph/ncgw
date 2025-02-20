extends Node2D

# XXX This game "state machine" is held together by hopes and dreams >_<

enum State {
	TITLE_SCREEN,
	PLAYING_REHEARSALS,
	PLAYING_REAL_DEAL,
	CREDITS,
}

var _rehearsals_count: int
var _challenge: Array[Round]
var _state: State:
	set(value):
		var old_val: State = _state
		_state = value
		if old_val != _state:
			_on_state_changed()

@onready var _leader: NpcDancer = %Leader
@onready var _player: PlayerDancer = %Player
@onready var _darkness: ColorRect = %Darkness
@onready var _title_screen: VBoxContainer = %TitleScreen
@onready var _finished_rehearsal_screen: VBoxContainer = %FinishedRehearsalScreen
@onready var _credits_screen: VBoxContainer = %CreditsScreen
@onready var _finished_label: RichTextLabel = %FinishedLabel
@onready var _round_count_label: Label = %RoundCountLabel
@onready var _rehearsals_count_label: Label = %RehearsalsCountLabel
@onready var _stage_lights_controller: StageLightsController = %StageLightsController


func _ready() -> void:
	_on_state_changed()


func _on_state_changed() -> void:
	_darkness.hide()
	_title_screen.hide()
	_credits_screen.hide()
	_finished_rehearsal_screen.hide()
	_finished_label.hide()
	_round_count_label.hide()
	_rehearsals_count_label.hide()
	_leader.btn_map_wheel.hide()
	_stage_lights_controller.turn_on_lights()
	
	match _state:
		State.TITLE_SCREEN:
			_rehearsals_count = 0
			_darkness.show()
			_title_screen.show()
		State.PLAYING_REHEARSALS:
			_rehearse()
		State.PLAYING_REAL_DEAL:
			_participate_in_contest()
		State.CREDITS:
			_darkness.show()
			_credits_screen.show()


func _generate_challenge() -> Array[Round]:
	var challenge: Array[Round] = [
		Round.new(
			[
				Round.Step.PRESS_LEFT_BTN,
				Round.Step.PRESS_LEFT_BTN,
			],
		),
		Round.new(
			[
				Round.Step.PRESS_LEFT_BTN,
			],
		),
		Round.new(
			[
				Round.Step.PRESS_LEFT_BTN,
				Round.Step.PRESS_UP_BTN,
				Round.Step.PRESS_DOWN_BTN,
				Round.Step.PRESS_RIGHT_BTN,
			]
		),
	]
	return challenge


func _rehearse() -> void:
	if _rehearsals_count < 1:
		_challenge = _generate_challenge()
	
	_rehearsals_count += 1
	_rehearsals_count_label.show()
	_rehearsals_count_label.text = "Rehearsal %s" % _rehearsals_count
	
	# Rehearsals always use default button map
	var btn_map: ButtonMap = ButtonMap.new()
	_leader.btn_map_wheel.show_button_map(btn_map, true)
	_player.btn_map = btn_map
	
	_darkness.hide()
	await create_tween().tween_interval(2.0).finished
	_player.bow()
	_leader.bow()
	await _leader.bowed
	await create_tween().tween_interval(1.0).finished
	_stage_lights_controller.turn_off_lights()
	_finished_label.visible_characters = 0
	_round_count_label.show()
	_round_count_label.text = ""
	var round_count: int = 0
	
	for curr_round: Round in _challenge:
		round_count += 1
		await create_tween().tween_interval(1.5).finished
		_stage_lights_controller.shine_light_on_leader()
		_round_count_label.text = \
				"Round %s of %s" % [round_count, _challenge.size()]
		_leader.btn_map_wheel.show()
		await create_tween().tween_interval(0.5).finished
		var steps: Array[Round.Step] = curr_round.steps
		_leader.perform_steps(steps)
		await _leader.steps_completed
		await create_tween().tween_interval(0.5).finished
		_stage_lights_controller.shine_light_on_player()
		_player.attempt_steps(steps)
		await _player.steps_completed
	_stage_lights_controller.turn_on_lights()
	_leader.btn_map_wheel.hide()
	await create_tween().tween_interval(2.0).finished
	_round_count_label.hide()
	var label_text_length: int = _finished_label.get_parsed_text().length()
	_rehearsals_count_label.hide()
	_finished_label.show()
	await create_tween().tween_property(_finished_label, "visible_characters", \
			label_text_length, 0.5).from(0).finished
	await create_tween().tween_interval(3.0).finished
	_finished_label.hide()
	_darkness.show()
	_finished_rehearsal_screen.show()


func _participate_in_contest() -> void:
	# TODO real deal
	await create_tween().tween_interval(3.0).finished
	_state = State.TITLE_SCREEN


func _on_start_rehearsal_btn_pressed() -> void:
	_state = State.PLAYING_REHEARSALS


func _on_practice_again_btn_pressed() -> void:
	_state = State.PLAYING_REHEARSALS
	_on_state_changed()


func _on_real_deal_button_pressed() -> void:
	_state = State.PLAYING_REAL_DEAL


func _on_to_title_screen_btn_pressed() -> void:
	_state = State.TITLE_SCREEN


func _on_show_credits_btn_pressed() -> void:
	_state = State.CREDITS
