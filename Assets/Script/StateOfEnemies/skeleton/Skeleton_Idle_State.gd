extends State_1_0

@export var idle_timer = 0.5
var can_transition = false
var can_transition_chase = false

func enter():
	super.enter()
	can_transition = false
	animation_player.play("Idle")
	await wait_for_idle()
	can_transition_chase = true
	
func wait_for_idle():
	await get_tree().create_timer(idle_timer).timeout
	can_transition = true
	
func transition():
	if can_transition_chase and owner.is_player_in_range:
		print("→ Switching to Chase State")
		get_parent().change_state("Chase State")
	elif can_transition:
		print("→ Switching to Patrol State")
		get_parent().change_state("Patrol State")
