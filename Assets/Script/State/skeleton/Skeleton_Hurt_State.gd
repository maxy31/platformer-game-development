extends State_1_0

var can_transition = false

func enter():
	super.enter()
	can_transition = false
	animation_player.play("Hurt")
	await animation_player.animation_finished
	can_transition = true
	
func transition():
	if can_transition:
		get_parent().change_state("Idle State")
	
