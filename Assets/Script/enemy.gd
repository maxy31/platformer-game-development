extends CharacterBody2D
class_name Enemy

@export var max_health := 3
@export var contact_damage := 1   # 碰到玩家时造成的伤害
var current_health := max_health

func _ready():
	# 确保有 HitBox（Area2D）并监听
	if has_node("HitBox"):
		$HitBox.body_entered.connect(_on_hitbox_body_entered)

# ==============
# 敌人受伤
# ==============
func take_damage(amount: int):
	current_health -= amount
	print("💥 Enemy took", amount, "damage. HP:", current_health)

	if current_health <= 0:
		die()

func die():
	print("☠ Enemy died")
	queue_free()

# ==============
# 玩家接触检测
# ==============
func _on_hitbox_body_entered(body):
	# 判断是否是玩家
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			print("⚠ Player touched enemy! Player takes ", contact_damage, " damage.")
			body.take_damage(contact_damage)
