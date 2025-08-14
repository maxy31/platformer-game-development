extends Node
class_name AttackAreaMap

@export var attack_area: Area2D

func do_attack_hit(damage: int):
	if not attack_area:
		print("❌ AttackArea 没绑定")
		return

	var bodies = attack_area.get_overlapping_bodies()
	print("🔍 攻击判定检测到物体: ", bodies)

	if bodies.size() == 0:
		print("⚠ 没有检测到任何物体，可能是 Layer/Mask 设置不对")
	
	for body in bodies:
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				print("💥 对敌人造成伤害: ", damage)
				body.take_damage(damage)
			else:
				print("⚠ 检测到敌人但它没有 take_damage 方法")
