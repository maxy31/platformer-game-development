extends CharacterBody2D
class_name DestroyerController

@export var speed := 10.0
@export var jump_power := 10.0
@export var max_health := 5
@export var attack_damage := 2
@export var attack_cooldown := 0.3

var current_health := max_health
var speed_multiplier := 30.0
var jump_multiplier := -30.0
var direction := 0.0
var is_attacking := false
var attack_timer := 0.0

@export var animator: Node
@export var combat_handler: Node

func _physics_process(delta: float) -> void:
	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	# 左右移动
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

	# 攻击冷却
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false

	# 攻击输入
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

func start_attack():
	print("🗡 攻击输入触发")
	is_attacking = true
	attack_timer = attack_cooldown

	if animator and animator.has_method("play_attack_animation"):
		print("🎬 调用动画播放函数")
		animator.play_attack_animation()
	else:
		print("⚠ 没有绑定 animator 或 play_attack_animation 方法")

	if combat_handler and combat_handler.has_method("do_attack_hit"):
		print("💥 调用攻击判定函数")
		combat_handler.do_attack_hit(attack_damage)
	else:
		print("⚠ 没有绑定 combat_handler 或 do_attack_hit 方法")

func take_damage(amount: int = 1):
	current_health -= amount
	print("💔 Player took damage. Current HP:", current_health)
	if current_health <= 0:
		die()

func die():
	print("☠ Player Died")
	queue_free()
