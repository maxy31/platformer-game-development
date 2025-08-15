extends CharacterBody2D
class_name DestroyerController

@export var speed := 5.0
@export var jump_power := 8.0
@export var max_health := 5
@export var attack_damage := 3

var current_health := max_health
var speed_multiplier := 30.0
var jump_multiplier := -30.0
var direction := 0.0

var is_attacking := false
var current_attack_index := 1
var queued_attack := false
var can_queue_attack := false   # cancel point 是否开启
var is_hurt := false

@export var animator: Node
@export var combat_handler: Node

func _physics_process(delta: float) -> void:
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
			queued_attack = true  # 改成动画期间任何时刻都能缓冲
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
	# 由动画中的 Call Method Track 调用
	can_queue_attack = true
	print("🎯 Cancel Point 触发，可以提前输入下一击")

func on_attack_animation_finished():
	if queued_attack:
		queued_attack = false
		current_attack_index += 1
		if current_attack_index > 2:
			current_attack_index = 1
		start_attack()
	else:
		is_attacking = false
		current_attack_index = 1


func take_damage(amount: int = 1):
	if is_hurt:  # 如果已经在受击，就不重复播放
		return

	current_health -= amount
	print("💔 Player took damage. Current HP:", current_health)

	if current_health <= 0:
		die()
		return

	# 进入受击状态
	is_hurt = true
	is_attacking = false
	queued_attack = false
	can_queue_attack = false

	# 播放受击动画
	if animator and animator.has_method("play_hurt_animation"):
		animator.play_hurt_animation()

func on_hurt_animation_finished():
	is_hurt = false

func die():
	print("☠ Player Died")
	queue_free()
