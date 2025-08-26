extends Area2D

@export var respawn_position: Vector2 = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1, global_position)
		body.global_position = respawn_position  # move back instead of reload
