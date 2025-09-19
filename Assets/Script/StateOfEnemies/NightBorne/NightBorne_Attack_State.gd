extends State_1_0

var can_transition = false

func enter():
	super.enter()
	can_transition = false
	animation_player.play("Attack")
	await animation_player.animation_finished
	can_transition = true
	owner.reset_attack_state()
	
func transition():
	if can_transition:
		if owner.is_player_in_range:
			get_parent().change_state("Chase State")
		else:
			get_parent().change_state("Idle State")
