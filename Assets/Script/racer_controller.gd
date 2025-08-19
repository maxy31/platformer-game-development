extends CharacterBody2D
class_name RacerController

@export var speed := 10.0
@export var jump_power := 8.0
@export var max_health := 5
@export var attack_damage := 1

@export var charge_attack_time: float = 1.0     # 蓄力时长（秒）
@export var charge_attack_damage: int = 2       # 冲锋攻击伤害
@export var body_attack_area: Area2D            # 绑定 BodyAttackArea
@export var heart_bar: HeartBar
@export var animator: Node
@export var combat_handler: Node

var current_health : int
var speed_multiplier := 30.0
var jump_multiplier := -30.0
var direction := 0.0

var is_attacking := false
var queued_attack := false
var is_hurt := false
# 冲锋模式变量
var move_timer: float = 0.0
var charge_attack_ready: bool = false

#boost jump
var jump_velocity = -400
var boosted_jump_velocity = -600  # stronger jump after cheese
var boost_time = 3.0              # seconds boost lasts
var is_boosted = false

# 自动回血相关
var regen_interval: float = 10.0   # 每10秒回血
var regen_timer: float = 0.0
signal health_changed(current: int, max: int)

func _ready():
	current_health = max_health
	# 同步“最大血量”和“当前血量”到 HeartBar
	if heart_bar:
		heart_bar.set_max_hearts(max_health)
		heart_bar.set_value(current_health)
	# 绑定 BodyAttackArea 的碰撞检测
	if body_attack_area:
		body_attack_area.body_entered.connect(_on_body_attack_area_entered)


func _physics_process(delta: float) -> void:
	# ======================
	#   自动回血逻辑
	# ======================
	if current_health < max_health:
		regen_timer += delta
		if regen_timer >= regen_interval:
			regen_timer = 0.0
			heal(1)

	# 如果受击中只处理物理，不响应其它输入
	if is_hurt:
		move_and_slide()
		return

	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if is_boosted:
			velocity.y = boosted_jump_velocity          #boost jump
		else:
			velocity.y = jump_power * jump_multiplier   #normal jump

	# 攻击输入（缓冲）
	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			start_attack()
		else:
			queued_attack = true
			print("⏩ 记录下一次攻击输入")

	# 移动 + 蓄力计时
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed * speed_multiplier

		# 计时：持续移动
		move_timer += delta
		if move_timer >= charge_attack_time:
			if not charge_attack_ready:
				print("⚡ 玩家进入冲锋攻击模式")
				charge_attack_ready = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

		# 停止移动则重置
		move_timer = 0.0
		charge_attack_ready = false

	move_and_slide()


func start_attack():
	# 开始攻击
	is_attacking = true

	# 播放动画（由 animator 控制）
	if animator and animator.has_method("play_attack_animation"):
		animator.play_attack_animation()

	# 立刻做一次攻击判定
	if combat_handler and combat_handler.has_method("do_attack_hit"):
		combat_handler.do_attack_hit(attack_damage)

	# 保险：如果 animation_finished 没触发，0.5s 后强制结束攻击状态
	var t = get_tree().create_timer(0.5)
	t.timeout.connect(Callable(self, "_force_end_attack"))


func _force_end_attack():
	# 保险回调 — 若仍在攻击则强制结束
	if is_attacking:
		print("⚠ 动画信号未触发，强制结束攻击状态")
		on_attack_animation_finished()


func on_attack_animation_finished():
	# 动画结束时由 animator 调用
	if queued_attack:
		queued_attack = false
		start_attack()
	else:
		is_attacking = false


func take_damage(amount: int = 1):
	# 受击
	if is_hurt:
		return

	current_health = max(0, current_health - amount)

	if heart_bar:
		heart_bar.set_value(current_health)
		
	emit_signal("health_changed", current_health, max_health)
	print("💔 Player took damage. Current HP:", current_health)

	if current_health <= 0:
		die()
		return

	is_hurt = true
	is_attacking = false
	queued_attack = false

	if animator and animator.has_method("play_hurt_animation"):
		animator.play_hurt_animation()


func heal(amount: int = 1):
	current_health = clamp(current_health + amount, 0, max_health)
	if heart_bar:
		heart_bar.set_value(current_health)
	emit_signal("health_changed", current_health, max_health)
	print("💖 Player healed. Current HP:", current_health)


func on_hurt_animation_finished():
	is_hurt = false


func die():
	print("☠ Player Died")
	queue_free()


# ======================
#   冲锋攻击检测
# ======================
func _on_body_attack_area_entered(body):
	if charge_attack_ready and body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			print("💥 冲锋攻击触发，对敌人造成 ", charge_attack_damage, " 点伤害")
			body.take_damage(charge_attack_damage)
		else:
			print("⚠ 敌人没有 take_damage 方法")

		# 攻击触发后重置（防止无限撞）
		move_timer = 0.0
		charge_attack_ready = false

#Boost Jump Cheese
func eat_food():
	is_boosted = true
	$BoostTimer.start(3.0)
	
func _on_boost_timer_timeout() -> void:
	is_boosted = false
