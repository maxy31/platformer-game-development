extends CharacterBody2D
class_name RacerController

@export var speed := 10.0
@export var jump_power := 8.0
@export var max_health := 5
@export var attack_damage := 1

var current_health := max_health
var speed_multiplier := 30.0
var jump_multiplier := -30.0
var direction := 0.0

var is_attacking := false
var queued_attack := false
var is_hurt := false

@export var animator: Node
@export var combat_handler: Node

func _physics_process(delta: float) -> void:
	# 如果受击中只处理物理，不响应其它输入
	if is_hurt:
		move_and_slide()
		return

	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# 攻击输入（缓冲）
	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			start_attack()
		else:
			queued_attack = true
			print("⏩ 记录下一次攻击输入")

	# 移动
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

func start_attack():
	# 开始攻击
	is_attacking = true

	# 播放动画（由 animator 控制）
	if animator and animator.has_method("play_attack_animation"):
		animator.play_attack_animation()

	# 立刻做一次攻击判定（如果你希望在动画中间才判定，可以把这段移动到 animator 的动画事件中）
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

	current_health -= amount
	print("💔 Player took damage. Current HP:", current_health)

	if current_health <= 0:
		die()
		return

	is_hurt = true
	is_attacking = false
	queued_attack = false

	if animator and animator.has_method("play_hurt_animation"):
		animator.play_hurt_animation()

func on_hurt_animation_finished():
	is_hurt = false

func die():
	print("☠ Player Died")
	queue_free()
