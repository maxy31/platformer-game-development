extends CharacterBody2D
class_name RacerController
signal player_died 

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

# ⚡ 新增：受伤相关
@export var knockback_force := 50.0
@export var knockback_up := -30.0
@export var invincible_duration := 0.1

@onready var audio_controller = $CharacterAudio

var is_in_ui_mode: bool = false

var current_health : int
var speed_multiplier := 30.0
var jump_multiplier := -30.0
var direction := 0.0

var is_attacking := false
var queued_attack := false
var is_hurt := false
var invincible_timer := 0.0        # ⚡ 无敌计时器
var _allow_jump_while_hurt_this_time := false  # ⚡ 地面受击立刻跳

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
	add_to_group("Player") #改成player
	current_health = max_health
	if heart_bar:
		heart_bar.set_max_hearts(max_health)
		heart_bar.set_value(current_health)

	if body_attack_area:
		body_attack_area.body_entered.connect(_on_body_attack_area_entered)


func _physics_process(delta: float) -> void:
	# ======================
	#   无敌计时 & 闪烁
	# ======================
	if invincible_timer > 0.0:
		invincible_timer -= delta
		if animator and animator.has_method("set_modulate_alpha"):
			# 交给 animator 控制闪烁，或直接修改 modulate
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
			
			audio_controller.play_health_regen_sound()

	# 如果受击中只处理物理，不响应其它输入
	if is_hurt:
		move_and_slide()
		return

	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 跳跃
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or _allow_jump_while_hurt_this_time:
			audio_controller.play_jump_sound()
			if is_boosted:
				velocity.y = boosted_jump_velocity
			else:
				velocity.y = jump_power * jump_multiplier
		# ⚡ 一次机会用完后重置
		_allow_jump_while_hurt_this_time = false
		

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
		audio_controller.start_racer_walk()
			
		move_timer += delta
		if move_timer >= charge_attack_time:
			if not charge_attack_ready:
				print("⚡ 玩家进入冲锋攻击模式")
				charge_attack_ready = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)
		audio_controller.stop_racer_walk()	
		move_timer = 0.0
		charge_attack_ready = false

	move_and_slide()


func start_attack():
	is_attacking = true
	if animator and animator.has_method("play_attack_animation"):
		animator.play_attack_animation()

	if combat_handler and combat_handler.has_method("do_attack_hit"):
		combat_handler.do_attack_hit(attack_damage)

	var t = get_tree().create_timer(0.5)
	t.timeout.connect(Callable(self, "_force_end_attack"))
	audio_controller.play_weapon_swoosh_sound()


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
		audio_controller.play_take_damage_sound()


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
	process_mode = Node.PROCESS_MODE_DISABLED
	hide() 
	emit_signal("player_died")
	audio_controller.play_game_over_sound()
	
	var ui = get_tree().current_scene.get_node("GameOverUI")
	if ui:
		ui.show_game_over()


# ======================
#   冲锋攻击检测
# ======================
func _on_body_attack_area_entered(body):
	if charge_attack_ready and body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			print("💥 冲锋攻击触发，对敌人造成 ", charge_attack_damage, " 点伤害")
			body.take_damage(charge_attack_damage)
			audio_controller.play_weapon_hit_sound()
		else:
			print("⚠ 敌人没有 take_damage 方法")

		move_timer = 0.0
		charge_attack_ready = false


#Boost Jump Cheese
func eat_food():
	is_boosted = true
	$BoostTimer.start(1.5)
	audio_controller.play_cheese_pickup_sound()
	
func _on_boost_timer_timeout() -> void:
	is_boosted = false

func enter_ui_mode():
	is_in_ui_mode = true
	velocity = Vector2.ZERO
	is_hurt = false
	is_attacking = false

func play_level_complete_sound():
	# --- ADD THIS DEBUGGING BLOCK ---
	if is_instance_valid(audio_controller):
		print("DEBUG (Player): 'play_level_complete_sound' called. The audio player IS valid. Playing sound.") #This line is shown
		audio_controller.play_level_complete_sound()
	else:
		# If you see this message, your @onready var path is WRONG.
		print("DEBUG (Player): FAILED! 'play_level_complete_sound' was called, but 'audio_level_completed' is NULL. Check the node path in the @onready var.")
	# --------------------------------

func play_weapon_hit_sound():
	#audio_weapon_hit.play()
	audio_controller.play_weapon_hit_sound()
