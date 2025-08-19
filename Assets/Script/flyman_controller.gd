extends CharacterBody2D
class_name FlymanController

@export var speed := 5.0
@export var jump_power := 8.0
@export var max_health := 5
@export var attack_damage := 1
@export var heart_bar: HeartBar
@export var animator: Node
@export var combat_handler: Node

var current_health : int
var speed_multiplier := 30.0
var jump_multiplier := -30.0
var direction := 0.0

var is_attacking := false
var current_attack_index := 1
var queued_attack := false
var can_queue_attack := false   # cancel point 是否开启

# 自动回血相关
var regen_interval: float = 10.0   # 每10秒回血
var regen_timer: float = 0.0

# 受击无敌相关
@export var invincible_time: float = 0.5   # 受伤后 0.5 秒无敌
var invincible_timer: float = 0.0

signal health_changed(current: int, max: int)

func _ready():
	current_health = max_health
	# 同步“最大血量”和“当前血量”到 HeartBar
	if heart_bar:
		heart_bar.set_max_hearts(max_health)
		heart_bar.set_value(current_health)

func _physics_process(delta: float) -> void:
	# ======================
	#   无敌时间倒计时
	# ======================
	if invincible_timer > 0.0:
		invincible_timer -= delta

	# ======================
	#   自动回血逻辑
	# ======================
	if current_health < max_health:
		regen_timer += delta
		if regen_timer >= regen_interval:
			regen_timer = 0.0
			heal(1)

	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# 攻击输入
	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			start_attack()
		else:
			queued_attack = true
			print("⏩ 攻击缓冲记录")

	# 移动
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

func start_attack():
	is_attacking = true
	can_queue_attack = false
	print("🗡 攻击阶段: attack", current_attack_index)

	if animator and animator.has_method("play_attack_animation"):
		animator.play_attack_animation(current_attack_index)

	if combat_handler and combat_handler.has_method("do_attack_hit"):
		combat_handler.do_attack_hit(attack_damage)

func on_attack_cancel_point():
	can_queue_attack = true
	print("🎯 Cancel Point 触发，可以提前输入下一击")

func on_attack_animation_finished():
	if queued_attack:
		queued_attack = false
		current_attack_index += 1
		if current_attack_index > 4:
			current_attack_index = 1
		start_attack()
	else:
		is_attacking = false
		current_attack_index = 1

func heal(amount: int = 1):
	current_health = clamp(current_health + amount, 0, max_health)
	if heart_bar:
		heart_bar.set_value(current_health)
	emit_signal("health_changed", current_health, max_health)
	print("💖 Player healed. Current HP:", current_health)

func take_damage(amount: int = 1):
	# 如果在无敌时间内，直接返回
	if invincible_timer > 0.0:
		return

	current_health = max(0, current_health - amount)

	if heart_bar:
		heart_bar.set_value(current_health)
	emit_signal("health_changed", current_health, max_health)
	print("💔 Player took damage. Current HP:", current_health)

	if current_health <= 0:
		die()
		return

	# 设置无敌时间
	invincible_timer = invincible_time

	# 播放受击动画
	if animator and animator.has_method("play_hurt_animation"):
		animator.play_hurt_animation()

func die():
	print("☠ Player Died")
	if animator and animator.has_method("play_die_animation"):
		animator.play_die_animation()
	else:
		queue_free()
