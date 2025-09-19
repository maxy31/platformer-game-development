extends Node2D

@export var damage_to_player : int = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Contacted with spike trap")
		body.take_damage(damage_to_player, global_position)
