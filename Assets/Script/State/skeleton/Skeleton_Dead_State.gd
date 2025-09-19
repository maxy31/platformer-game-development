extends State_1_0

var is_dead = false

func enter():
	if is_dead:
		return
	super.enter()
	animation_player.play("Dead")
	await animation_player.animation_finished
	
	is_dead = true
