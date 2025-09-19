extends State_1_0

@onready var ray_cast_right = $"../../RayCast/RayCastRight"
@onready var ray_cast_left = $"../../RayCast/RayCastLeft"

var can_transition = false

func enter():
	super.enter()
	can_transition = false
	owner.mandatory_idle_active = false
	owner.reset_attack_state()
	animation_player.play("Patrol-Chase")
	can_transition = true

func transition():
	if can_transition:
		if owner.is_close_to_player:
			get_parent().change_state("Attack State")
		elif owner.mandatory_idle_active and (ray_cast_left.is_colliding() or ray_cast_right.is_colliding()):
			get_parent().change_state("Mandatory Idle State")
		elif not owner.is_player_in_range:
			get_parent().change_state("Idle State")
