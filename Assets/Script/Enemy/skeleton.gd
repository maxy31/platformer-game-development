extends CharacterBody2D

@onready var player_detection_area = $PlayerDetection
@onready var animation_player = $AnimationPlayer
@onready var finite_state_machine = $FiniteStateMachine
@onready var sprite_2d = $Sprite2D
@onready var ray_cast_right = $RayCast/RayCastRight
@onready var ray_cast_left = $RayCast/RayCastLeft
@onready var attack_area = $AttackArea2D
@onready var monster_spotted: AudioStreamPlayer2D = $Monster_Spotted
@onready var monster_walk_growl: AudioStreamPlayer2D = $Monster_Walk_Growl
@onready var skeleton_axe_swing: AudioStreamPlayer2D = $Skeleton_Axe_Swing
@export var attack_cooldown : float = 1.5 # Attack cooldown time (in seconds)

var player = null  # Don't initialize here, will be set in _ready()
var can_attack: bool = true  # Whether can attack or not
var mandatory_idle_active = false
var is_player_in_range = false #for chase
var is_close_to_player = false #for attack
var direction = Vector2.RIGHT
var is_dead = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var change_direction : float = 2.0
@export var stop_distance : float = 10.0
@export var attack_range : float = 35.0
@export var damage_dealt : int = 1
@export var move_speed = 28
@export var chase_speed = 60
@export var health = 5
@export var knockback_force = Vector2(250, -15)

func _ready():
	# Wait a frame to ensure the player exists
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("Player")
	monster_walk_growl.play()
	
	if player:
		print("Player found for skeleton")
	else:
		print("Player not found for skeleton - check player group")
	
	# Initialize the state machine to start in Idle state
	if finite_state_machine:
		finite_state_machine.change_state("Idle State")
		monster_walk_growl.play()
	else:
		push_error("FiniteStateMachine node not found!")
	
func _physics_process(delta):
	# Check if player exists before accessing it
	if not player:
		# Try to find player again
		player = get_tree().get_first_node_in_group("Player")
		if not player:
			# If player still not found, skip processing
			if not is_on_floor():
				velocity.y += gravity * delta
			move_and_slide()
			return
	
	var player_position = player.global_position
	var distance_to_player = global_position.distance_to(player_position)
	var direction_to_player_x = player_position.x - global_position.x
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
		
	if is_player_in_range:
		monster_spotted.play()
		if abs(direction_to_player_x) > change_direction:
			direction.x = sign(direction_to_player_x)
			sprite_2d.flip_h = direction.x < 0
	
	if is_player_in_range == false:
		check_wall_collision()	
		
	if distance_to_player <= attack_range and mandatory_idle_active == false:
		start_attack_animation()
	
	if is_player_in_range and ray_cast_right.is_colliding() and direction == Vector2.RIGHT:
		mandatory_transition()
	if is_player_in_range and ray_cast_left.is_colliding() and direction == Vector2.LEFT:
		mandatory_transition()
		
	if is_player_in_range and finite_state_machine.check_if_can_move():
		if abs(direction_to_player_x) > stop_distance:
			velocity.x = direction.x * chase_speed
		else:
			velocity.x = 0
	else:
		if finite_state_machine.check_if_can_move():
			velocity.x = direction.x * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
	
	update_attack_area_direction()
	move_and_slide()
			
func mandatory_transition():
	mandatory_idle_active = true
		
func update_attack_area_direction():
	if direction == Vector2.RIGHT:
		attack_area.scale.x = 1
	else:
		attack_area.scale.x = -1
			
func check_wall_collision():
	if ray_cast_right.is_colliding():
		direction = Vector2.LEFT
		sprite_2d.flip_h = true
	if ray_cast_left.is_colliding():
		direction = Vector2.RIGHT
		sprite_2d.flip_h = false
	
func start_attack_animation():
	skeleton_axe_swing.play()
	if not can_attack:
		return  # In cooldown, cannot attack
	
	is_close_to_player = true
	can_attack = false # Entering cooldown
	# Play attack animation
	
	# Activate cooldown timer
	var cooldown_timer = get_tree().create_timer(attack_cooldown)
	cooldown_timer.timeout.connect(_reset_attack_cooldown)
	
func _reset_attack_cooldown():
	can_attack = true

func _on_player_detected(body):
	if body.is_in_group("Player"):
		is_player_in_range = true
		
func _on_player_lost(body):
	if body.is_in_group("Player"):
		is_player_in_range = false
		
func _on_attack_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage_dealt)
		
func reset_attack_state():
	is_close_to_player = false
		
func take_damage(damage):
	if is_dead:
		return
		
	print("Skeleton taking damage: ", damage)
	health -= damage
	print("Skeleton health: ", health)
	
	# Check if player exists before using it for knockback
	if player:
		var player_position = player.global_position
		var knockback_direction = (global_position - player_position).normalized()
		apply_knockback(Vector2(knockback_force.x * knockback_direction.x, knockback_force.y))
	else:
		# Apply generic knockback if player not found
		apply_knockback(Vector2(knockback_force.x * -direction.x, knockback_force.y))
	
	if health <= 0:
		print("Skeleton should die now")
		die()
	else:
		print("Skeleton going to hurt state")
		finite_state_machine.change_state("Hurt State")
	
func apply_knockback(force: Vector2):
	velocity = force
	move_and_slide()
	
func die():
	is_dead = true
	finite_state_machine.change_state("Dead State")
