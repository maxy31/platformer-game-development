extends CharacterBody2D
class_name FlymanController
signal player_died 

@export var speed := 5.0
@export var jump_power := 8.0
@export var max_health := 5
@export var attack_damage := 1

@export var heart_bar: HeartBar
@export var animator: Node
@export var combat_handler: Node

# Contact with ongoing harm related
@export var contact_area: Area2D
@export var contact_damage: int = 1
@export var contact_damage_interval: float = 0.4

# Invulnerable flashing state variables
@export var flicker_target: CanvasItem
@export var invincible_time: float = 0.5
@export var flicker_interval: float = 0.1

# Knockback
@export var knockback_force: float = 250.0
@export var knockback_up: float = -150.0

# Attack buffer Mode
@export var attack_buffer_on_hurt: bool = true

@onready var audio_controller = $CharacterAudio

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

# Automatic Health Regeneration
var regen_interval: float = 10.0
var regen_timer: float = 0.0

# Continuous Damage
var _contact_list: Array[Node] = []
var _contact_cd: float = 0.0

#boost jump
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
	# Invincibility timer + flicker
	if invincible_timer > 0.0:
		invincible_timer -= delta
		_handle_invincible_flicker(delta)
	else:
		_stop_invincible_flicker()

	# Auto health regeneration
	if current_health < max_health:
		regen_timer += delta
		if regen_timer >= regen_interval:
			regen_timer = 0.0
			heal(1)
			audio_controller.play_health_regen_sound()

	# Continuous contact damage
	_process_contact_damage(delta)

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump: Can jump immediately if hit on the ground; must wait for animation to finish if hit in the air
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and ((not is_hurt) or _allow_jump_while_hurt_this_time):
			audio_controller.play_jump_sound()
		# Check if in a boosted jump state
			if is_boosted:
				velocity.y = boosted_jump_velocity      # Use boosted jump velocity
			else:
				velocity.y = jump_power * jump_multiplier  # Use normal jump velocity

	# Attack input
	if Input.is_action_just_pressed("attack"):
		if not is_attacking and not is_hurt:
			start_attack()
		elif is_hurt and attack_buffer_on_hurt:
			queued_attack = true
			print("⚡ Attack input buffered while hurt")
		elif is_attacking:
			queued_attack = true
			print("⏩ Attack buffer recorded")

	# Moving
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed * speed_multiplier
		audio_controller.start_character_walk()
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)
		audio_controller.stop_character_walk()

	move_and_slide()

# Attack Logic
func start_attack():
	is_attacking = true
	can_queue_attack = false
	print("🗡 Attack phase: attack", current_attack_index)

	if animator and animator.has_method("play_attack_animation"):
		animator.play_attack_animation(current_attack_index)
		audio_controller.play_punch_swoosh_sound()

	if combat_handler and combat_handler.has_method("do_attack_hit"):
		combat_handler.do_attack_hit(attack_damage)

func on_attack_cancel_point():
	can_queue_attack = true

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

# Can jump immediately if hit on the ground; jump is locked until animation finishes if hit in the air
	_allow_jump_while_hurt_this_time = is_on_floor()

	# Interrupt attack
	is_attacking = false
	current_attack_index = 1
	can_queue_attack = false

	# Enter hurt & invincible state
	is_hurt = true
	_start_invincibility_fx()

	# Knockback
	if from_pos != Vector2.ZERO:
		var dir = sign(global_position.x - from_pos.x)
		velocity.x = dir * knockback_force
		velocity.y = knockback_up

	# Play hurt animation
	if animator and animator.has_method("play_hurt_animation"):
		animator.play_hurt_animation()
		audio_controller.play_take_damage_sound()

func on_hurt_animation_finished():
	is_hurt = false
	_allow_jump_while_hurt_this_time = false
	print("✅ Hurt animation finished, unlocking controls")

	# If there was an attack input during the hurt state, trigger it immediately after finishing
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
	process_mode = Node.PROCESS_MODE_DISABLED
	hide() 
	emit_signal("player_died")
	audio_controller.play_game_over_sound()

# Continuous damage
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

# # Invicibility
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

#Boost Jump Cheese
func eat_food():
	is_boosted = true
	$BoostTimer.start(1.5)
	audio_controller.play_cheese_pickup_sound()
	
func _on_boost_timer_timeout() -> void:
	is_boosted = false

func enter_ui_mode():
	is_in_ui_mode = true
	# Resetting velocity and state here is optional, but helps ensure the character is completely still
	velocity = Vector2.ZERO 
	is_hurt = false
	is_attacking = false
	
# === Called when character is loaded into an actual game level ===
func exit_ui_mode():
	is_in_ui_mode = false
	set_physics_process(true)
	set_process(true)

func play_level_complete_sound():
	if is_instance_valid(audio_controller):
		audio_controller.play_level_complete_sound()
	else:
		print("DEBUG (Player): FAILED! 'play_level_complete_sound' was called, but 'audio_level_completed' is NULL. Check the node path in the @onready var.")
		
func play_punch_hit_sound():
	if is_instance_valid(audio_controller):
		audio_controller.play_punch_hit_sound()
