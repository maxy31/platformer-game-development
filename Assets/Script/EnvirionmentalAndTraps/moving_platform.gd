extends AnimatableBody2D

@export var move_speed := 100.0
@export var left_limit := -75.0  # How far left it goes from start
@export var right_limit := 15.0  # How far right it goes from start

var move_direction := Vector2.RIGHT
var start_position := Vector2.ZERO

func _ready():
	start_position = position  # Save the original starting point

func _physics_process(delta):
	position += move_direction * move_speed * delta

	# Check bounds
	if position.x <= start_position.x + left_limit:
		position.x = start_position.x + left_limit
		move_direction = Vector2.RIGHT

	elif position.x >= start_position.x + right_limit:
		position.x = start_position.x + right_limit
		move_direction = Vector2.LEFT
