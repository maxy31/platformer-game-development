extends State_1_0

@export var ranged_attack_scene: PackedScene
var can_transition = false

func enter():
	super.enter()
	can_transition = false
	animation_player.play("Attack")
	await animation_player.animation_finished
	can_transition = true
	owner.reset_attack_state()

func fire():
	var fire_attack = ranged_attack_scene.instantiate()
	fire_attack.position = global_position + Vector2(-1.5, 3)
	
	get_tree().current_scene.call_deferred("add_child", fire_attack)

func transition():
	if can_transition:
		if owner.is_player_in_range:
			get_parent().change_state("Chase State")
		else:
			get_parent().change_state("Idle State")
