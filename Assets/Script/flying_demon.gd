extends CharacterBody2D

@onready var player_detection_area = $PlayerDetection
@onready var animation_player = $AnimationPlayer
@onready var finite_state_machine = $FiniteStateMachine
@onready var sprite_2d = $Sprite2D

var player = null  # 添加玩家引用变量
var is_player_in_range = false #for chase
var attack_1_range = false #for attack
var direction : Vector2
var is_dead = false

@export var stop_distance : float = 125.0
@export var attack_range : float = 150.0
@export var move_speed = 15
@export var chase_speed = 20
@export var health = 10
@export var knockback_force = Vector2(100, -100)

func _ready():
	# Get player reference
	player = get_tree().get_first_node_in_group("Player")
	if player:
		print("Player found")
	else:
		print("Player not found - check player group")
	
	# Initialize direction
	direction = Vector2.RIGHT  # Or any default direction
	
func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		if not player:
			return
	
	# Reset velocity each frame
	velocity = Vector2.ZERO
	
	var distance_to_player = global_position.distance_to(player.global_position)
	var player_position = player.global_position
	var direction_to_player = (player_position - global_position).normalized()
	
	if distance_to_player <= attack_range:
		start_attack_animation()
		
	if is_player_in_range:
		if direction_to_player.x != 0:
			sprite_2d.flip_h = direction_to_player.x < 0	
			
	if is_player_in_range and finite_state_machine.check_if_can_move():
		if distance_to_player > stop_distance:
			velocity = direction_to_player * chase_speed
		else:
			velocity = Vector2.ZERO
	else:
		if finite_state_machine.check_if_can_move():
			velocity = direction * move_speed
		else:
			velocity = Vector2.ZERO
	
	move_and_slide()
	
func start_attack_animation():
	attack_1_range = true
	
func _on_random_patrol_timer_timeout():
	$RandomPatrolTimer.wait_time = choose([0.6,0.8,1.0])
	if is_player_in_range == false and finite_state_machine.check_if_can_move():
		direction = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,])

func choose(array):
	array.shuffle()
	return array.front()
	
func _on_player_detected(body):
	if body.is_in_group("Player"):
		is_player_in_range = true
		
func _on_player_lost(body):
	if body.is_in_group("Player"):
		is_player_in_range = false
		
func reset_attack_state():
	attack_1_range = false
		
func take_damage(damage):
	if is_dead:
		return
	health -= damage
	print(health)		
	
	# 修复这里的 Global 引用
	if player:
		var player_position = player.global_position
		var knockback_direction = (global_position - player_position).normalized()
		apply_knockback(Vector2(knockback_force.x * knockback_direction.x, knockback_force.y))
		
	if health <= 0:
		die()
	else:
		finite_state_machine.change_state("Hurt State")

func apply_knockback(force: Vector2):
	velocity = force
	move_and_slide()
	
func die():
	is_dead = true
	finite_state_machine.change_state("Dead State")
