class_name ChallengeGenerator
extends RefCounted


const ALLOWED_TRAPS: Array[Round.Traps] = [
	Round.Traps.INVERT_VERT_BTNS,
	Round.Traps.INVERT_HOR_BTNS,
]


func generate() -> Array[Round]:
	var challenge: Array[Round] = []
	# Round 1
	challenge.append(Round.new(_gen_steps(1)))
	## Round 2
	#challenge.append(Round.new(_gen_steps(4)))
	## Round 3
	#challenge.append(Round.new(_gen_steps(2)))
	## Round 4
	#challenge.append(Round.new(_gen_steps(5)))
	## Round 5
	#challenge.append(Round.new(_gen_steps(3)))
	## Round 6
	#challenge.append(Round.new(_gen_steps(4), _gen_traps(ALLOWED_TRAPS)))
	## Round 7
	#challenge.append(Round.new(_gen_steps(3), _gen_traps(ALLOWED_TRAPS)))
	## Round 8
	#challenge.append(Round.new(_gen_steps(8), Round.Traps.REVERSE_STEPS))
	return challenge


func _gen_steps(count: int) -> Array[Round.Step]:
	if count <= 0:
		return []
	
	var steps: Array[Round.Step] = []
	for i: int in count:
		steps.append(Round.Step.values().pick_random())
	return steps


func _gen_traps(allowed_traps: Array[Round.Traps]) -> int:
	var traps: int = 0
	for i: int in allowed_traps.size():
		traps |= allowed_traps.pick_random()
	return traps
