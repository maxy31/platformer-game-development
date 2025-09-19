extends Node
class_name FlowmasterAttackAreaMap

@export var attack_area: Area2D
@export var player: FlowmasterController

func do_attack_hit(damage: int):
	if not attack_area:
		print("❌ AttackArea not bound")
		return

	var bodies = attack_area.get_overlapping_bodies()
	print("🔍 Attack detection found objects: ", bodies)

	if bodies.size() == 0:
		print("⚠ No objects detected, Layer/Mask settings might be incorrect")
	
	for body in bodies:
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				player.play_magic_cast_sound()
				print("💥 Dealing damage to enemy: ", damage)
				body.take_damage(damage)
			else:
				print("⚠ Detected an enemy but it doesn't have a take_damage method")
