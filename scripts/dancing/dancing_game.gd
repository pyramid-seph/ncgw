extends Node2D

# XXX This game "state machine" is held together by hopes and dreams >_<

enum State {
	TITLE_SCREEN,
	PLAYING_REHEARSALS,
	PLAYING_REAL_DEAL,
	CREDITS,
}

const SFX_CRUSH = preload("res://assets/audio/sfx/sfx_crush.wav")

var _challenge_gen: ChallengeGenerator = ChallengeGenerator.new()
var _nailed_steps: int
var _failed_steps: int
var _max_step_streak: int
var _curr_step_streak: int
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
@onready var _finished_container: PanelContainer = %FinishedLabel
@onready var _round_count_label: Label = %RoundCountLabel
@onready var _rehearsals_count_label: Label = %RehearsalsCountLabel
@onready var _stage_lights_controller: StageLightsController = %StageLightsController
@onready var _courtains: Courtains = %Courtains
@onready var _crowd: Node2D = %Crowd
@onready var _foot: Sprite2D = %Foot
@onready var _results: CenterContainer = %Results
@onready var _failures_label: Label = %FailuresLabel
@onready var _nailed_score_label: Label = %NailedScoreLabel
@onready var _rehearsals_score_label: Label = %RehearsalsScoreLabel
@onready var _you_are_label: Label = %YouAreLabel
@onready var _total_score_label: Label = %TotalScoreLabel


func _ready() -> void:
	_on_state_changed()


func _on_state_changed() -> void:
	_crowd.hide()
	_darkness.hide()
	_title_screen.hide()
	_credits_screen.hide()
	_finished_rehearsal_screen.hide()
	_finished_container.hide()
	_round_count_label.hide()
	_rehearsals_count_label.hide()
	_leader.btn_map_wheel.hide()
	_stage_lights_controller.turn_on_lights()
	_failures_label.hide()
	_results.hide()
	_player.show()
	_leader.show()
	_foot.position.y = -150
	
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


func _rehearse() -> void:
	_nailed_steps = 0
	_failed_steps = 0
	_max_step_streak = 0
	_curr_step_streak = 0
	
	if _rehearsals_count < 1:
		_challenge = _challenge_gen.generate()
	
	_courtains.close(true)
	
	_rehearsals_count += 1
	_rehearsals_count_label.show()
	_rehearsals_count_label.text = "Rehearsal %s" % _rehearsals_count
	_failures_label.text = "Fails: %s" % _failed_steps
	
	# Rehearsals always use default button map
	var btn_map: ButtonMap = ButtonMap.new()
	_leader.btn_map_wheel.show_button_map(btn_map, true)
	_player.btn_map = btn_map
	
	_darkness.hide()
	await create_tween().tween_interval(2.0).finished
	_courtains.open() # TODO This should only happen on the real deal
	await _courtains.opened
	await create_tween().tween_interval(2.0).finished
	_player.bow()
	_leader.bow()
	await _leader.bowed
	await create_tween().tween_interval(1.0).finished
	_stage_lights_controller.turn_off_lights()
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
	await create_tween().tween_interval(3.0).finished
	_courtains.close() # TODO This should only happen on the real deal
	await _courtains.closed
	_round_count_label.hide()
	_rehearsals_count_label.hide()
	_finished_container.show()
	await create_tween().tween_interval(3.0).finished
	_finished_container.hide()
	_darkness.show()
	_finished_rehearsal_screen.show()


func _participate_in_contest() -> void:
	_nailed_steps = 0
	_failed_steps = 0
	_max_step_streak = 0
	_curr_step_streak = 0
	
	if _challenge.is_empty():
		_challenge = _challenge_gen.generate()
	
	_courtains.close(true)
	_crowd.show()
	_failures_label.show()
	_failures_label.text = "Fails: %s" % _failed_steps
	
	_darkness.hide()
	await create_tween().tween_interval(2.0).finished
	_courtains.open()
	await _courtains.opened
	await create_tween().tween_interval(2.0).finished
	_player.bow()
	_leader.bow()
	await _leader.bowed
	await create_tween().tween_interval(1.0).finished
	_stage_lights_controller.turn_off_lights()
	_round_count_label.show()
	_round_count_label.text = ""
	var round_count: int = 0
	
	for curr_round: Round in _challenge:
		round_count += 1
		await create_tween().tween_interval(1.5).finished
		_stage_lights_controller.shine_light_on_leader()
		_round_count_label.text = \
				"Round %s of %s" % [round_count, _challenge.size()]
		
		# Set traps
		#   > Button map traps
		var btn_map_changed: bool = false
		var btn_map: ButtonMap = ButtonMap.new()
		Log.d("Round %s has these traps: %s" % [round_count, curr_round.traps])
		if curr_round.traps & Round.Traps.INVERT_VERT_BTNS:
			Log.d("Round %s has invert VERT trap." % round_count)
			btn_map_changed = true
			btn_map.up = &"btn_down"
			btn_map.down = &"btn_up"
		if curr_round.traps & Round.Traps.INVERT_HOR_BTNS:
			Log.d("Round %s has invert HOR trap." % round_count)
			btn_map_changed = true
			btn_map.left = &"btn_right"
			btn_map.right = &"btn_left"
		_player.btn_map = btn_map
		_leader.btn_map_wheel.show()
		var skip_roulette_anim: bool = not btn_map_changed
		_leader.btn_map_wheel.show_button_map(btn_map, skip_roulette_anim)
		await _leader.btn_map_wheel.new_btn_config_shown
		
		#   > Reverse steps trap
		await create_tween().tween_interval(0.5).finished
		var steps: Array[Round.Step] = curr_round.steps.duplicate()
		if curr_round.traps & Round.Traps.REVERSE_STEPS:
			Log.d("Round %s has reverse trap." % round_count)
			steps.reverse()
		
		if OS.is_debug_build():
			Log.d("Correct inputs are: %s" % _get_steps_as_string(steps))
		
		_leader.perform_steps(steps)
		await _leader.steps_completed
		await create_tween().tween_interval(0.5).finished
		_stage_lights_controller.shine_light_on_player()
		_player.attempt_steps(steps)
		await _player.steps_completed
	
	_stage_lights_controller.turn_on_lights()
	_leader.btn_map_wheel.hide()
	# TODO Play some claps
	_player.bow()
	_leader.bow()
	await _leader.bowed
	await create_tween().tween_interval(1.0).finished
	_courtains.close()
	await _courtains.closed
	_round_count_label.hide()
	_rehearsals_count_label.hide()
	_failures_label.hide()
	_finished_container.show()
	await create_tween().tween_interval(3.0).finished
	_finished_container.hide()
	
	var nailed_score: int = _nailed_steps * 100
	var rehearsals_penalty: int = maxi(0, _rehearsals_count - 1) * 25
	var total_score: int = maxi(0, nailed_score - rehearsals_penalty)
	var total_steps: int = _challenge.reduce(_accum_steps, 0)
	var is_perfect: bool = _nailed_steps == total_steps
	_nailed_score_label.text = "%s correct step(s) = %s" % [_nailed_steps, nailed_score]
	_rehearsals_score_label.text = "%s rehearsal(s) = -%s" % [_rehearsals_count, rehearsals_penalty]
	_total_score_label.text = "TOTAL: %s" % total_score
	if is_perfect:
		_you_are_label.text = "You are PERFECT!"
	else:
		_you_are_label.text = "You are not perfect."
	_results.show()
	await create_tween().tween_interval(3).finished
	_results.hide()
	
	if is_perfect:
		_courtains.open()
		await _courtains.opened
		await create_tween().tween_interval(1).finished
		# TODO More people cheering!
		for i: int in 2:
			_leader.bow()
			await _leader.bowed
			_player.bow()
			await _player.bowed
		var ending_tween: Tween = create_tween()
		ending_tween.tween_property(_foot, "position:y", -13, 0.1).from(-150)
		ending_tween.tween_callback(_player.hide)
		ending_tween.tween_callback(_leader.hide)
		ending_tween.tween_property(_foot, "position:y", -4, 0.05)
		ending_tween.tween_callback(SoundManager.play_sound.bind(SFX_CRUSH))
		await ending_tween.finished
		await create_tween().tween_interval(4.0).finished
	else:
		await create_tween().tween_interval(1.0).finished
	_state = State.TITLE_SCREEN


func _accum_steps(accum, this_round) -> int:
	return accum + this_round.steps.size()


func _get_steps_as_string(steps: Array[Round.Step]) -> String:
	var result: String = "[ "
	for step: Round.Step in steps:
		match step:
			Round.Step.PRESS_LEFT_BTN:
				result += " <-, "
			Round.Step.PRESS_RIGHT_BTN:
				result += " ->, "
			Round.Step.PRESS_UP_BTN:
				result += " ^, "
			Round.Step.PRESS_DOWN_BTN:
				result += " v "
	result += " ]"
	return result


func _on_player_step_attempted(_step: Round.Step, success: bool) -> void:
	if success:
		_nailed_steps += 1
	else:
		_failed_steps += 1
		_failures_label.text = "Fails: %s" % _failed_steps


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
