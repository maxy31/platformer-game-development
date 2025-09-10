extends CharacterBody2D
class_name DestroyerController

@export var speed := 5.0
@export var jump_power := 8.0
@export var max_health := 5
@export var attack_damage := 3
@export var heart_bar: HeartBar
@export var animator: Node          # hurt 动画结束请从 Animator 调用 on_hurt_animation_finished()
@export var combat_handler: Node
# Contact with ongoing harm related
@export var contact_area: Area2D
@export var contact_damage: int = 1
@export var contact_damage_interval: float = 0.4
# Unbeatable Flashing
@export var flicker_target: CanvasItem
@export var invincible_time: float = 0.5
@export var flicker_interval: float = 0.1
# Repulse
@export var knockback_force: float = 250.0
@export var knockback_up: float = -150.0
# Attack buffer Mode
@export var attack_buffer_on_hurt: bool = true

var is_in_ui_mode: bool = false

var current_health : int
var speed_multiplier := 30.0
var jump_multiplier := -30.0
var direction := 0.0
# Attack
var is_attacking := false
var current_attack_index := 1
var queued_attack := false
var can_queue_attack := false
# Hit/Invincible/Flash
var is_hurt: bool = false
var invincible_timer: float = 0.0
var _flicker_time_left: float = 0.0
var _flicker_accum: float = 0.0
var _flicker_state: bool = false
# When hit on the ground, you can jump immediately / When hit in the air, you can lock jump
var _allow_jump_while_hurt_this_time: bool = false
# Automatic Blood Replenishment
var regen_interval: float = 10.0
var regen_timer: float = 0.0
# Continuous Contact Injury
var _contact_list: Array[Node] = []
var _contact_cd: float = 0.0
# Boost Jump
var jump_velocity = -400
var boosted_jump_velocity = -600  # stronger jump after cheese
var boost_time = 3.0              # seconds boost lasts
var is_boosted = false
signal health_changed(current: int, max: int)

func _ready():
	current_health = max_health
	if heart_bar:
		heart_bar.set_max_hearts(max_health)
		heart_bar.set_value(current_health)

	if contact_area:
		if contact_area.has_signal("body_entered"):
			contact_area.body_entered.connect(_on_contact_area_body_entered)
		if contact_area.has_signal("body_exited"):
			contact_area.body_exited.connect(_on_contact_area_body_exited)

func _physics_process(delta: float) -> void:
	# 无敌计时 + 闪烁
	if invincible_timer > 0.0:
		invincible_timer -= delta
		_handle_invincible_flicker(delta)
	else:
		_stop_invincible_flicker()

	# 自动回血
	if current_health < max_health:
		regen_timer += delta
		if regen_timer >= regen_interval:
			regen_timer = 0.0
			heal(1)

	# 接触持续伤害
	_process_contact_damage(delta)

	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta

# 跳跃：地面受击可立刻跳；空中受击要等动画结束
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if (not is_hurt) or _allow_jump_while_hurt_this_time:
		# 检查是否处于跳跃增强状态
			if is_boosted:
				velocity.y = boosted_jump_velocity      # 使用增强跳跃力
			else:
				velocity.y = jump_power * jump_multiplier  # 使用普通跳跃力

	# 攻击输入
	if Input.is_action_just_pressed("attack"):
		if not is_attacking and not is_hurt:
			start_attack()
		elif is_hurt and attack_buffer_on_hurt:
			queued_attack = true
			print("⚡ 攻击输入在受击中被缓冲")
		elif is_attacking:
			queued_attack = true
			print("⏩ 攻击缓冲记录")

	# move
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

# Attack Logic
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

# Take damage and heal
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

	# 地面受击可立刻跳；空中受击锁跳直到动画结束
	_allow_jump_while_hurt_this_time = is_on_floor()

	# 打断攻击
	is_attacking = false
	current_attack_index = 1
	can_queue_attack = false

	# 进入受击 & 无敌
	is_hurt = true
	_start_invincibility_fx()

	# 击退
	if from_pos != Vector2.ZERO:
		var dir = sign(global_position.x - from_pos.x)
		velocity.x = dir * knockback_force
		velocity.y = knockback_up

	# 播放受击动画
	if animator and animator.has_method("play_hurt_animation"):
		animator.play_hurt_animation()

func on_hurt_animation_finished():
	is_hurt = false
	_allow_jump_while_hurt_this_time = false
	print("✅ 受击动画结束，解锁操作")

	# 如果受击中有攻击输入，播完立即触发
	if queued_attack:
		queued_attack = false
		start_attack()

func heal(amount: int = 1):
	current_health = clamp(current_health + amount, 0, max_health)
	if heart_bar:
		heart_bar.set_value(current_health)
	emit_signal("health_changed", current_health, max_health)
	print("💖 Player healed. Current HP:", current_health)

func die():
	print("☠ Player Died")
	if animator and animator.has_method("play_die_animation"):
		animator.play_die_animation()
	else:
		queue_free()

# Continuous take damage
func _on_contact_area_body_entered(body: Node) -> void:
	if body and body.is_in_group("Enemy"):
		if not _contact_list.has(body):
			_contact_list.append(body)

func _on_contact_area_body_exited(body: Node) -> void:
	_contact_list.erase(body)

func _process_contact_damage(delta: float) -> void:
	if _contact_list.is_empty():
		_contact_cd = 0.0
		return
	if invincible_timer > 0.0:
		return
	if _contact_cd > 0.0:
		_contact_cd -= delta
		return

	var src: Node = _contact_list[0]
	var src_pos: Vector2 = global_position
	if src is Node2D:
		src_pos = (src as Node2D).global_position

	take_damage(contact_damage, src_pos)
	_contact_cd = contact_damage_interval

# Invicibility
func _start_invincibility_fx():
	invincible_timer = invincible_time
	_flicker_time_left = invincible_time
	_flicker_accum = 0.0
	_flicker_state = false
	_apply_flicker_state(true)

func _handle_invincible_flicker(delta: float) -> void:
	if not flicker_target:
		return
	_flicker_time_left = max(0.0, _flicker_time_left - delta)
	_flicker_accum += delta
	if _flicker_accum >= flicker_interval:
		_flicker_accum = 0.0
		_flicker_state = not _flicker_state
		_apply_flicker_state(_flicker_state)
	if _flicker_time_left <= 0.0:
		_stop_invincible_flicker()

func _apply_flicker_state(dim: bool) -> void:
	if flicker_target:
		flicker_target.visible = not dim

func _stop_invincible_flicker() -> void:
	if flicker_target:
		flicker_target.visible = true
	_flicker_time_left = 0.0
	_flicker_accum = 0.0
	_flicker_state = false

# Boost Jump Cheese
func eat_food():
	is_boosted = true
	$BoostTimer.start(1.5)
	
func _on_boost_timer_timeout() -> void:
	is_boosted = false

func enter_ui_mode():
	is_in_ui_mode = true
	# 这里的速度和状态重置是可选的，但有助于确保角色完全静止
	velocity = Vector2.ZERO 
	is_hurt = false
	is_attacking = false
