extends Node2D

var current_state: State_1_0
var previous_state: State_1_0

func _ready():
	current_state = get_child(0) as State_1_0
	previous_state = current_state
	current_state.enter()
	
func change_state(state):
	if state == previous_state.name:
		return

	print("Changing state from ", previous_state.name, " to ", state)
	current_state = find_child(state) as State_1_0
	current_state.enter()
	
	previous_state.exit()
	previous_state = current_state
		
func check_if_can_move():
	return current_state.can_move
	
