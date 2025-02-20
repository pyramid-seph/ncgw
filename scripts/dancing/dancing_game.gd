extends Node2D

# XXX This game flow is held together by hopes and dreams >_<

enum State {
	TITLE_SCREEN,
	PLAYING_REHEARSALS,
	PLAYING_REAL_DEAL,
	CREDITS,
}

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


func _ready() -> void:
	_on_state_changed()


func _on_state_changed() -> void:
	_darkness.hide()
	_title_screen.hide()
	_credits_screen.hide()
	_finished_rehearsal_screen.hide()
	
	match _state:
		State.TITLE_SCREEN:
			_darkness.show()
			_title_screen.show()
		State.PLAYING_REHEARSALS:
			rehearse()
		State.PLAYING_REAL_DEAL:
			participate_in_contest()
		State.CREDITS:
			_darkness.show()
			_credits_screen.show()


func rehearse() -> void:
	# TODO rehearse
	await get_tree().create_timer(3.0, false).timeout
	_darkness.show()
	_finished_rehearsal_screen.show()


func participate_in_contest() -> void:
	# TODO real deal
	await get_tree().create_timer(3.0, false).timeout
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
