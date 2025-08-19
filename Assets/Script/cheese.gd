extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("eat_food"):
			body.eat_food()
			print("+1 Cheese! Boost activated!")
			hide()
			$CollisionShape2D.disabled = true
			$RespawnTimer.start()  # start the respawn timer


func _on_respawn_timer_timeout() -> void:
	show()
	$CollisionShape2D.disabled = false
