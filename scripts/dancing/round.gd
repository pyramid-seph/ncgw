class_name Round
extends RefCounted

enum Step {
	PRESS_LEFT_BTN,
	PRESS_RIGHT_BTN,
	PRESS_UP_BTN,
	PRESS_DOWN_BTN,
}

var steps: Array[Step]


func _init(init_steps: Array[Step]) -> void:
	steps = init_steps
