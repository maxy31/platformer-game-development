extends Node2D

signal level_completed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("level_completed")
