extends Node2D

@export var player_controller: FlymanController
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D
@export var attack_damage := 1

# --- Combo 系统变量 ---
var attack_index := 0  # 当前攻击段数（1～4）
var combo_timeout := 0.5  # 连击最大间隔
var combo_timer := 0.0
var is_attacking := false
var attack_queued := false

func _ready():
	# 连接动画结束信号
	animation_player.animation_finished.connect(_on_animation_finished)

func _process(delta):
	if not player_controller:
		return

	var vel = player_controller.velocity

	# --- Combo 计时器 ---
	if is_attacking and combo_timer > 0:
		combo_timer -= delta
	elif is_attacking:
		_reset_combo()

	# --- Sprite 朝向 ---
	if player_controller.direction == 1:
		sprite.flip_h = false
	elif player_controller.direction == -1:
		sprite.flip_h = true
	
		# --- 攻击范围翻转位置 ---
	var attack_area = $AttackArea
	if attack_area:
		var offset = 20
		attack_area.position.x = offset * player_controller.direction

	# --- 动画控制（非攻击状态下） ---
	if not is_attacking:
		if not player_controller.is_on_floor():
			if vel.y < 0.0:
				animation_player.play("jump")
			elif vel.y > 0.0:
				animation_player.play("fall")
		elif abs(vel.x) > 0.1:
			animation_player.play("move")
		else:
			animation_player.play("idle")
			
	if Input.is_action_just_pressed("attack"):
		if is_attacking:
			if attack_index < 4:
				attack_index += 1
				combo_timer = combo_timeout
				_play_attack_animation()
		else:
			_start_attack()


func _start_attack():
	is_attacking = true
	attack_index = 1
	combo_timer = combo_timeout
	_play_attack_animation()

func _play_attack_animation():
	match attack_index:
		1:
			animation_player.play("attack1")
			_check_attack_hit()
		2:
			animation_player.play("attack2")
			_check_attack_hit()
		3:
			animation_player.play("attack3")
			_check_attack_hit()
		4:
			animation_player.play("attack4")
			_check_attack_hit()
		_:
			_reset_combo()

func _on_animation_finished(anim_name):
	if anim_name.begins_with("attack"):
		if attack_queued and attack_index < 4:
			attack_index += 1
			combo_timer = combo_timeout
			attack_queued = false
			_play_attack_animation()
		else:
			_reset_combo()

func _check_attack_hit():
	var bodies = $AttackArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				body.take_damage(attack_damage)


func _reset_combo():
	is_attacking = false
	attack_index = 0
	attack_queued = false
	combo_timer = 0.0
