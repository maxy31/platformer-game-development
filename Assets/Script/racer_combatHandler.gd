extends Node
class_name RacerAttackAreaMap

@export var attack_area: Area2D

@export var player: RacerController

func do_attack_hit(damage: int):
	if not attack_area:
		print("❌ AttackArea 没绑定")
		return

	var bodies = attack_area.get_overlapping_bodies()
	print("🔍 攻击判定检测到物体: ", bodies)

	if bodies.size() == 0:
		print("⚠ 没有检测到任何物体，可能是 Layer/Mask 设置不对")
		# --- IMPORTANT: If we hit nothing, we can exit early. ---
		return

	# --- MODIFICATION: Use a flag to play the sound only once. ---
	var did_hit_enemy = false

	for body in bodies:
		if body.is_in_group("Enemy"):
			# Set the flag to true because we successfully hit something.
			did_hit_enemy = true

			if body.has_method("take_damage"):
				print("💥 对敌人造成伤害: ", damage)
				body.take_damage(damage)
			else:
				print("⚠ 检测到敌人但它没有 take_damage 方法")

	# --- FINAL STEP: After checking all enemies, play the sound if the flag is true. ---
	if did_hit_enemy:
		# Safety check to make sure the player is valid and has the function.
		if is_instance_valid(player) and player.has_method("play_weapon_hit_sound"):
			player.play_weapon_hit_sound()
		else:
			print("❌ Combat handler cannot find player or 'play_weapon_hit_sound' function!")
