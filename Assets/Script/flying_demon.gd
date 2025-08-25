extends CharacterBody2D

@onready var player_detection_area = $PlayerDetection
@onready var animation_player = $AnimationPlayer
@onready var finite_state_machine = $FiniteStateMachine
@onready var sprite_2d = $Sprite2D

var player = null
var is_player_in_range = false
var attack_1_range = false
var direction : Vector2 = Vector2.RIGHT
var is_dead = false

@export var attack_range : float = 150.0
@export var move_speed = 400
@export var chase_speed = 800
@export var acceleration = 10.0   # ✅ 加速平滑因子
@export var health = 4
@export var knockback_force = Vector2(100, -100)

# ✅ 新增：攻击冷却
@export var attack_cooldown : float = 1.5
var can_attack: bool = true

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if player:
		print("Player found: ", player.name)
	else:
		print("Player not found - check player group")
		return
	
	direction = Vector2.RIGHT
	
	if player_detection_area:
		if not player_detection_area.body_entered.is_connected(_on_player_detected):
			player_detection_area.body_entered.connect(_on_player_detected)
		if not player_detection_area.body_exited.is_connected(_on_player_lost):
			player_detection_area.body_exited.connect(_on_player_lost)
		print("PlayerDetection signals connected")
	else:
		print("ERROR: PlayerDetection area not found!")
	
	if has_node("RandomPatrolTimer"):
		$RandomPatrolTimer.start()

func _physics_process(delta: float) -> void:
	if not player or is_dead:
		return
	
	var distance_to_player = position.distance_to(player.position)
	var direction_to_player = (player.position - position).normalized()
	
	# 翻转精灵朝向
	if direction_to_player.x != 0:
		sprite_2d.flip_h = direction_to_player.x < 0
	
	# 移动逻辑
	var target_velocity = Vector2.ZERO
	
	if is_player_in_range and finite_state_machine.check_if_can_move():
		# 一直追逐玩家
		target_velocity = direction_to_player * chase_speed

		# 进入攻击范围就触发攻击，但不停止移动
		if distance_to_player <= attack_range:
			start_attack_animation()
	else:
		# 玩家不在范围内 → 巡逻
		if finite_state_machine.check_if_can_move():
			target_velocity = direction * move_speed
	
	# ✅ 平滑过渡，避免卡顿
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	
	move_and_slide()

func start_attack_animation():
	if not attack_1_range and can_attack: # ✅ 只有能攻击时才执行
		attack_1_range = true
		can_attack = false
		finite_state_machine.change_state("Attack State")
		
		# ✅ 冷却计时
		var cooldown_timer = get_tree().create_timer(attack_cooldown)
		cooldown_timer.timeout.connect(_reset_attack_cooldown)

func _reset_attack_cooldown():
	can_attack = true

func _on_random_patrol_timer_timeout():
	$RandomPatrolTimer.wait_time = choose([0.6, 0.8, 1.0])
	if not is_player_in_range and finite_state_machine.check_if_can_move():
		direction = choose([Vector2.RIGHT, Vector2.LEFT])

func choose(array):
	array.shuffle()
	return array.front()
	
func _on_player_detected(body):
	if body.is_in_group("Player"):
		is_player_in_range = true
		print("Player detected! Starting chase...")
		
func _on_player_lost(body):
	if body.is_in_group("Player"):
		is_player_in_range = false
		print("Player lost. Returning to patrol...")
		
func reset_attack_state():
	attack_1_range = false
		
func take_damage(damage):
	if is_dead:
		return
	health -= damage
	print("Health: ", health)		
	
	if player:
		var knockback_direction = (global_position - player.global_position).normalized()
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
	print("Enemy died")
