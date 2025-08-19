extends CharacterBody2D
class_name Enemy

@export var max_health := 3
@export var contact_damage := 1       # 碰到玩家时造成的伤害
@export var attack_interval := 1.0    # 每隔多少秒造成一次伤害

var current_health := max_health

# 玩家接触列表
var players_in_contact: Array = []
# 给每个玩家单独存冷却
var attack_timers := {}

func _ready():
	if has_node("HitBox"):
		$HitBox.body_entered.connect(_on_hitbox_body_entered)
		$HitBox.body_exited.connect(_on_hitbox_body_exited)

func _physics_process(delta: float) -> void:
	# 遍历所有接触到的玩家
	for player in players_in_contact:
		if not is_instance_valid(player):
			continue

		# 更新该玩家的攻击计时器
		if not attack_timers.has(player):
			attack_timers[player] = 0.0

		attack_timers[player] -= delta

		# 可以造成伤害
		if attack_timers[player] <= 0.0:
			if player.has_method("take_damage"):
				print("⚠ 持续伤害：对玩家造成 ", contact_damage, " 点伤害")
				player.take_damage(contact_damage, global_position)
				attack_timers[player] = attack_interval  # 重置计时

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
	if body.is_in_group("Player"):
		if not players_in_contact.has(body):
			players_in_contact.append(body)
			attack_timers[body] = 0.0   # 进入时立即可造成一次伤害

func _on_hitbox_body_exited(body):
	if players_in_contact.has(body):
		players_in_contact.erase(body)
		attack_timers.erase(body)
