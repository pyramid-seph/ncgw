class_name Round
extends RefCounted


enum Step {
	PRESS_LEFT_BTN,
	PRESS_RIGHT_BTN,
	PRESS_UP_BTN,
	PRESS_DOWN_BTN,
}

enum Traps {
	NONE = 0,
	INVERT_VERT_BTNS = 1,
	INVERT_HOR_BTNS = 2,
	REVERSE_STEPS = 8,
}

var steps: Array[Step]
var traps: int


func _init(init_steps: Array[Step], init_traps: int = Traps.NONE) -> void:
	steps = init_steps
	traps = init_traps
