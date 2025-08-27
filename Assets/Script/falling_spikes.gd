extends Node2D

@export var speed = 160.0
@export var damage_to_player : int = 1
var current_speed = 0.0

# Displaying layer issue

func _physics_process(delta: float) -> void:
	position.y += current_speed * delta;

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RacerController or body.is_in_group("Player"):
		print("Player is hit");
		body.take_damage(damage_to_player, global_position)
		queue_free()
		
func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	print("Player entered detection zone");
	fall();

func fall():
	current_speed = speed;
	await get_tree().create_timer(5).timeout # wait for 5 seconds, then continue below
	queue_free()
