extends State_1_0

var can_transition = false

func enter():
	super.enter()
	can_transition = false
	owner.reset_attack_state()
	animation_player.play("Patrol-Chase")
	can_transition = true

func transition():
	if can_transition:
		if owner.attack_1_range:
			get_parent().change_state("Attack State")
		elif not owner.is_player_in_range:
			get_parent().change_state("Idle State")
