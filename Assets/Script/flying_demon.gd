extends CharacterBody2D

@onready var player_detection_area = $PlayerDetection
@onready var animation_player = $AnimationPlayer
@onready var finite_state_machine = $FiniteStateMachine
@onready var sprite_2d = $Sprite2D

# 远程攻击相关节点
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

# 攻击系统变量
var can_attack: bool = true
var attack_cooldown_timer: Timer

func _ready():
	# 连接检测区域信号
	if player_detection_area:
		player_detection_area.body_entered.connect(_on_player_detected)
		player_detection_area.body_exited.connect(_on_player_lost)
	
	# 连接动画结束信号
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
	
	# 创建攻击冷却计时器
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.wait_time = attack_cooldown_time
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_reset_attack_cooldown)
	add_child(attack_cooldown_timer)
	
	# 初始查找玩家
	_find_player()

func _physics_process(delta: float) -> void:
	# 查找玩家
	if not player or not is_instance_valid(player):
		_find_player()
		if not player:
			return
	
	if is_dead:
		return
	
	# 计算距离和方向
	var distance_to_player = position.distance_to(player.position)
	var direction_to_player = (player.position - position).normalized()
	
	# 翻转精灵
	sprite_2d.flip_h = direction_to_player.x < 0
	
	# 移动逻辑 - 保持距离
	var target_velocity = Vector2.ZERO
	
	if is_player_in_range:
		# 智能移动：保持最佳攻击距离
		if distance_to_player > attack_range:
			# 太远了，靠近玩家
			target_velocity = direction_to_player * chase_speed
		elif distance_to_player < min_attack_range:
			# 太近了，后退
			target_velocity = -direction_to_player * chase_speed * 0.7
		else:
			# 在最佳攻击距离，停止移动
			target_velocity = Vector2.ZERO
		
		# 检查攻击条件
		if distance_to_player >= min_attack_range and distance_to_player <= attack_range and can_attack:
			start_attack_animation()
	
	# 应用移动
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	move_and_slide()

func start_attack_animation():
	# 检查状态机是否允许攻击
	if finite_state_machine:
		if finite_state_machine.has_method("can_attack") and not finite_state_machine.can_attack():
			return
		if finite_state_machine.has_method("is_busy") and finite_state_machine.is_busy():
			return
	
	if can_attack:
		can_attack = false
		
		# 通过状态机触发攻击
		if finite_state_machine and finite_state_machine.has_method("change_state"):
			finite_state_machine.change_state("Attack State")
		else:
			if animation_player and animation_player.has_animation("attack"):
				animation_player.play("attack")
		
		# 发射投射物
		_launch_projectile()
		
		# 启动冷却计时器
		attack_cooldown_timer.start()

# 发射投射物函数
func _launch_projectile():
	if not player or not is_instance_valid(player):
		return
	
	# 计算发射方向
	var direction_to_player = (player.position - position).normalized()
	
	# 创建投射物实例
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		
		# 设置投射物位置和方向
		if attack_point:
			projectile.position = attack_point.global_position
		else:
			projectile.position = global_position
		
		projectile.direction = direction_to_player
		
		# 添加到场景
		get_parent().add_child(projectile)

func _reset_attack_cooldown():
	can_attack = true

func _find_player():
	# 从全局数据获取
	if GlobalData and GlobalData.has_method("get_current_player"):
		player = GlobalData.get_current_player()
		if player:
			return
	
	# 从场景中查找
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
		# 动画结束后回到追逐状态
		if finite_state_machine and finite_state_machine.has_method("change_state"):
			finite_state_machine.change_state("Chase State")

# 受伤功能
func take_damage(damage):
	if is_dead:
		return
	
	health -= damage
	
	if health <= 0:
		die()
	else:
		# 受伤状态
		if finite_state_machine and finite_state_machine.has_method("change_state"):
			finite_state_machine.change_state("Hurt State")

func die():
	is_dead = true
	
	if finite_state_machine and finite_state_machine.has_method("change_state"):
		finite_state_machine.change_state("Dead State")
	
	# 停止所有行为
	set_physics_process(false)
