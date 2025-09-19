extends AnimatableBody2D

@export var move_speed: float = 0.5
var path_follow: PathFollow2D
var path_direction: int = 1

func _ready():
	path_follow = get_parent() as PathFollow2D
	if path_follow == null:
		push_error("This node must be a child of PathFollow2D!")

func _physics_process(delta: float) -> void:
	if path_follow == null:
		return  # Do nothing if not correctly parented

	path_follow.progress += move_speed * path_direction
	var progress_ratio := path_follow.progress_ratio

	if progress_ratio <= 0.0 or progress_ratio >= 1.0:
		path_direction *= -1
