extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("eat_food"):
		body.eat_food()
		print("+1 Cheese! Boost activated!")

		# Defer changes until safe
		hide()
		$CollisionShape2D.call_deferred("set_disabled", true)
		$RespawnTimer.start()
		
func _on_respawn_timer_timeout() -> void:
	# Show the cheese again
	show()
	 # Re-enable the collision shape so it can be picked up again
	$CollisionShape2D.disabled = false
