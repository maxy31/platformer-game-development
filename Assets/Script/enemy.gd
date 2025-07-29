extends CharacterBody2D

@export var max_health := 3
var current_health := max_health

func take_damage(amount: int):
	current_health -= amount
	print("Enemy took", amount, "damage. HP:", current_health)
	if current_health <= 0:
		die()

func die():
	print("Enemy died")
	queue_free()
