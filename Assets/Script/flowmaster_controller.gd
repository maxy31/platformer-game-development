extends CharacterBody2D
class_name FlowmasterController

@export var speed := 9.0
@export var jump_power := 9.0
@export var max_health := 3
@export var attack_damage := 2

@export var charge_attack_time: float = 1.0     # 蓄力时长（秒）
@export var charge_attack_damage: int = 2       # 冲锋攻击伤害
@export var heart_bar: HeartBar
@export var animator: Node
@export var combat_handler: Node

# ⚡ 新增：受伤相关
@export var knockback_force := 30.0
@export var knockback_up := -10.0
@export var invincible_duration := 0.5

var current_health : int
var speed_multiplier := 30.0
var jump_multiplier := -30.0
var direction := 0.0

var is_attacking := false
var queued_attack := false
var is_hurt := false
var invincible_timer := 0.0        # ⚡ 无敌计时器
var _allow_jump_while_hurt_this_time := false  # ⚡ 地面受击立刻跳

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
	if heart_bar:
		heart_bar.set_max_hearts(max_health)
		heart_bar.set_value(current_health)

func _physics_process(delta: float) -> void:
	# ======================
	#   无敌计时 & 闪烁
	# ======================
	if invincible_timer > 0.0:
		invincible_timer -= delta
		if animator and animator.has_method("set_modulate_alpha"):
			animator.set_modulate_alpha(0.5 + 0.5 * sin(Time.get_ticks_msec() / 50.0))
	else:
		if animator and animator.has_method("set_modulate_alpha"):
			animator.set_modulate_alpha(1.0)

	# 自动回血逻辑
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

	# ✅ 左右移动
	var input_dir = Input.get_axis("move_left", "move_right")

	if input_dir != 0:
		velocity.x = input_dir * speed * speed_multiplier
		# ✅ 根据方向翻转角色
		if input_dir > 0:
			animator.scale.x = 1
		elif input_dir < 0:
			animator.scale.x = -1
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	# 跳跃
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or _allow_jump_while_hurt_this_time:
			if is_boosted:
				velocity.y = boosted_jump_velocity
			else:
				velocity.y = jump_power * jump_multiplier
		_allow_jump_while_hurt_this_time = false

	# 攻击输入（缓冲）
	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			start_attack()
		else:
			queued_attack = true
			print("⏩ 记录下一次攻击输入")

	move_and_slide()

func start_attack():
	is_attacking = true
	if animator and animator.has_method("play_attack_animation"):
		animator.play_attack_animation()

	if combat_handler and combat_handler.has_method("do_attack_hit"):
		combat_handler.do_attack_hit(attack_damage)

	var t = get_tree().create_timer(0.5)
	t.timeout.connect(Callable(self, "_force_end_attack"))


func _force_end_attack():
	if is_attacking:
		print("⚠ 动画信号未触发，强制结束攻击状态")
		on_attack_animation_finished()


func on_attack_animation_finished():
	if queued_attack:
		queued_attack = false
		start_attack()
	else:
		is_attacking = false


# ⚡ 修改：take_damage 增加 from_pos & 无敌 & 击退
func take_damage(amount: int = 1, from_pos: Vector2 = Vector2.ZERO):
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

	# 地面受击可以立即跳
	_allow_jump_while_hurt_this_time = is_on_floor()

	is_hurt = true
	is_attacking = false
	queued_attack = false

	# ⚡ 击退
	if from_pos != Vector2.ZERO:
		var dir = sign(global_position.x - from_pos.x)
		velocity.x = dir * knockback_force
		velocity.y = knockback_up

	# ⚡ 开启无敌
	invincible_timer = invincible_duration

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

#Boost Jump Cheese
func eat_food():
	is_boosted = true
	$BoostTimer.start(3.0)
	
func _on_boost_timer_timeout() -> void:
	is_boosted = false
