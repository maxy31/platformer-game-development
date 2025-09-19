extends CharacterBody2D

@onready var player_detection_area = $PlayerDetection
@onready var animation_player = $AnimationPlayer
@onready var finite_state_machine = $FiniteStateMachine
@onready var sprite_2d = $Sprite2D

# Ranged attack related nodes
@onready var attack_point = $AttackPoint
@onready var projectile_scene = preload("res://Assets/Scenes/Enemy/fireball.tscn")

var player = null
var is_player_in_range = false
var is_dead = false

@export var attack_range : float = 150.0
@export var min_attack_range : float = 50.0
@export var chase_speed = 400
@export var acceleration = 8.0
@export var health = 3
@export var attack_cooldown_time : float = 2.0

# Attack system variables
var can_attack: bool = true
var attack_cooldown_timer: Timer

func _ready():
	# Connect detection area signals
	if player_detection_area:
		player_detection_area.body_entered.connect(_on_player_detected)
		player_detection_area.body_exited.connect(_on_player_lost)
	
	# Connect animation finished signal
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
	
	# Create attack cooldown timer
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.wait_time = attack_cooldown_time
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_reset_attack_cooldown)
	add_child(attack_cooldown_timer)
	
	# Initial player search
	_find_player()

func _physics_process(delta: float) -> void:
	# Find the player
	if not player or not is_instance_valid(player):
		_find_player()
		if not player:
			return
	
	if is_dead:
		return
	
	# Calculate distance and direction
	var distance_to_player = position.distance_to(player.position)
	var direction_to_player = (player.position - position).normalized()
	
	# Flip the sprite
	sprite_2d.flip_h = direction_to_player.x < 0
	
	# Movement logic - maintain distance
	var target_velocity = Vector2.ZERO
	
	if is_player_in_range:
		# Smart movement: maintain optimal attack distance
		if distance_to_player > attack_range:
			# Too far, move closer to the player
			target_velocity = direction_to_player * chase_speed
		elif distance_to_player < min_attack_range:
			# Too close, move back
			target_velocity = -direction_to_player * chase_speed * 0.7
		else:
			# At optimal attack distance, stop moving
			target_velocity = Vector2.ZERO
		
		# Check attack conditions
		if distance_to_player >= min_attack_range and distance_to_player <= attack_range and can_attack:
			start_attack_animation()
	
	# Apply movement
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	move_and_slide()

func start_attack_animation():
	# Check if the state machine allows attacking
	if finite_state_machine:
		if finite_state_machine.has_method("can_attack") and not finite_state_machine.can_attack():
			return
		if finite_state_machine.has_method("is_busy") and finite_state_machine.is_busy():
			return
	
	if can_attack:
		can_attack = false
		
		# Trigger attack through the state machine
		if finite_state_machine and finite_state_machine.has_method("change_state"):
			finite_state_machine.change_state("Attack State")
		else:
			if animation_player and animation_player.has_animation("attack"):
				animation_player.play("attack")
		
		# Launch projectile
		_launch_projectile()
		
		# Start cooldown timer
		attack_cooldown_timer.start()

# Launch projectile function
func _launch_projectile():
	if not player or not is_instance_valid(player):
		return
	
	# Calculate launch direction
	var direction_to_player = (player.position - position).normalized()
	
	# Create projectile instance
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		# Set projectile position and direction
		if attack_point:
			projectile.position = attack_point.global_position
		else:
			projectile.position = global_position
		
		projectile.direction = direction_to_player
		
		# Add to the scene
		get_parent().add_child(projectile)

func _reset_attack_cooldown():
	can_attack = true

func _find_player():
	# Get from global data
	if GlobalData and GlobalData.has_method("get_current_player"):
		player = GlobalData.get_current_player()
		if player:
			return
	
	# Find in the scene
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _on_player_detected(body):
	if body.is_in_group("Player"):
		is_player_in_range = true
		player = body

func _on_player_lost(body):
	if body.is_in_group("Player"):
		is_player_in_range = false

func _on_animation_finished(anim_name: String):
	if anim_name == "attack":
		# Return to chase state after animation finishes
		if finite_state_machine and finite_state_machine.has_method("change_state"):
			finite_state_machine.change_state("Chase State")

func take_damage(damage):
	if is_dead:
		return
	
	health -= damage
	
	if health <= 0:
		die()
	else:
		# Hurt state
		if finite_state_machine and finite_state_machine.has_method("change_state"):
			finite_state_machine.change_state("Hurt State")

func die():
	is_dead = true
	
	if finite_state_machine and finite_state_machine.has_method("change_state"):
		finite_state_machine.change_state("Dead State")
	
	# Stop all behavior
	set_physics_process(false)
