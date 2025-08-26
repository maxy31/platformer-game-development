extends State_1_0

var can_transition = false
@onready var ray_cast_right = $"../../RayCast/RayCastRight"
@onready var ray_cast_left = $"../../RayCast/RayCastLeft"

func enter():
	super.enter()
	can_transition = false
	animation_player.play("Idle")
	can_transition = true
	
func transition():
	if can_transition:
		if owner.is_player_in_range and ray_cast_right.is_colliding() and owner.direction == Vector2.LEFT:
			get_parent().change_state("Chase State")
		elif owner.is_player_in_range and ray_cast_left.is_colliding() or owner.direction == Vector2.RIGHT:
			get_parent().change_state("Chase State")
		elif not owner.is_player_in_range:
			get_parent().change_state("Idle State")
