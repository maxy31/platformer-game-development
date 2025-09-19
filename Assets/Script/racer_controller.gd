extends CharacterBody2D
class_name RacerController
signal player_died 

@export var speed := 10.0
@export var jump_power := 8.0
@export var max_health := 5
@export var attack_damage := 1

@export var charge_attack_time: float = 1.0     # Charge duration (seconds)
@export var charge_attack_damage: int = 2       # Charge attack damage
@export var body_attack_area: Area2D            # Binds to BodyAttackArea
@export var heart_bar: HeartBar
@export var animator: Node
@export var combat_handler: Node

# ⚡ Damage related variables
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
var invincible_timer := 0.0        # ⚡ Invincibility timer
var _allow_jump_while_hurt_this_time := false  # ⚡ Allow immediate jump if hit on the ground

# Charge status changes
var move_timer: float = 0.0
var charge_attack_ready: bool = false

#boost jump
var jump_velocity = -400
var boosted_jump_velocity = -600  # stronger jump after cheese
var boost_time = 3.0              # seconds boost lasts
var is_boosted = false

# Automatic Health Regeneration
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
	# Invincibility Timer & Flashing
	if invincible_timer > 0.0:
		invincible_timer -= delta
		if animator and animator.has_method("set_modulate_alpha"):
			# 交给 animator 控制闪烁，或直接修改 modulate
			# Animator handles flashing, or modify modulate value directly
			animator.set_modulate_alpha(0.5 + 0.5 * sin(Time.get_ticks_msec() / 50.0))
	else:
		if animator and animator.has_method("set_modulate_alpha"):
			animator.set_modulate_alpha(1.0)

	# Auto health regeneration
	if current_health < max_health:
		regen_timer += delta
		if regen_timer >= regen_interval:
			regen_timer = 0.0
			heal(1)
			
			audio_controller.play_health_regen_sound()

	# If hurt, only process physics and don't respond to other input
	if is_hurt:
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or _allow_jump_while_hurt_this_time:
			audio_controller.play_jump_sound()
			if is_boosted:
				velocity.y = boosted_jump_velocity
			else:
				velocity.y = jump_power * jump_multiplier
		# ⚡ Reset after 1 usage
		_allow_jump_while_hurt_this_time = false
		

	# Attack input (buffering)
	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			start_attack()
		else:
			queued_attack = true
			print("⏩ Queueing the next attack input")

	# Moving + Charging state Timer
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed * speed_multiplier
		audio_controller.start_racer_walk()
			
		move_timer += delta
		if move_timer >= charge_attack_time:
			if not charge_attack_ready:
				print("⚡ Player entering charging state")
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
		print("⚠ Animation signal not triggered, forcing end of attack state")
		on_attack_animation_finished()


func on_attack_animation_finished():
	if queued_attack:
		queued_attack = false
		start_attack()
	else:
		is_attacking = false


# ⚡ take_damage adds from_pos & invincibility & knockback
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

	# Can jump immediately if hit on the ground; jump is locked until animation finishes if hit in the air
	_allow_jump_while_hurt_this_time = is_on_floor()

	is_hurt = true
	is_attacking = false
	queued_attack = false

	# ⚡ Knockback
	if from_pos != Vector2.ZERO:
		var dir = sign(global_position.x - from_pos.x)
		velocity.x = dir * knockback_force
		velocity.y = knockback_up

	# ⚡ Knockback
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

	audio_controller.play_game_over_sound()

	emit_signal("player_died")

	var ui = get_tree().current_scene.get_node("GameOverUI")
	if ui:
		ui.show_game_over()


# Charging attack detection
func _on_body_attack_area_entered(body):
	if charge_attack_ready and body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			print("💥 Triggering charging attack, dealing to enemy ", charge_attack_damage, " damage")
			body.take_damage(charge_attack_damage)
			audio_controller.play_weapon_hit_sound()
		else:
			print("⚠ Detected an enemy but it doesn't have a take_damage method")

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
	if is_instance_valid(audio_controller):
		audio_controller.play_level_complete_sound()

func play_weapon_hit_sound():
	audio_controller.play_weapon_hit_sound()
