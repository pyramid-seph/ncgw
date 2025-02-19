class_name Round
extends Resource

enum Step {
	WAIT,
	PRESS_LEFT_BTN,
	PRESS_RIGHT_BTN,
	PRESS_UP_BTN,
	PRESS_DOWN_BTN,
}

@export var steps: Array[Step]
