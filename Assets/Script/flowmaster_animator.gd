extends Node2D
class_name FlowmasterAnimator

@export var player_controller: FlowmasterController
@export var animated_sprite: AnimatedSprite2D   # 角色本体
@export var attackM: AnimatedSprite2D           # MiddleAttackEffect
@export var attackE: AnimatedSprite2D           # EndAttackEffect
@export var attack_area: Area2D

var attack_animation_name := "attack1"

func _ready():
	# 默认隐藏特效
	if attackM:
		attackM.visible = false
	if attackE:
		attackE.visible = false

	# 普通动画结束
	if animated_sprite:
		animated_sprite.animation_finished.connect(Callable(self, "_on_animation_finished"))

	# 攻击特效结束（Godot4 推荐：bind sender）
	if attackM:
		attackM.animation_finished.connect(Callable(self, "_on_attack_effect_finished").bind(attackM))
	if attackE:
		attackE.animation_finished.connect(Callable(self, "_on_attack_effect_finished").bind(attackE))

# 攻击动作（角色）
func play_attack_animation():
	if not animated_sprite:
		return

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(attack_animation_name):
		print("🎬 播放攻击動畫:", attack_animation_name)

		# 播放角色攻击动作
		animated_sprite.animation = attack_animation_name
		animated_sprite.frame = 0
		animated_sprite.play()

		# 播放攻击特效
		if attackM and attackM.sprite_frames and attackM.sprite_frames.has_animation("attack1"):
			attackM.visible = true
			attackM.animation = "attack1"
			attackM.frame = 0
			attackM.play()

		if attackE and attackE.sprite_frames and attackE.sprite_frames.has_animation("attack1"):
			attackE.visible = true
			attackE.animation = "attack1"
			attackE.frame = 0
			attackE.play()
	else:
		print("❌ 找不到攻击动画:", attack_animation_name)

# 角色动画播放结束
func _on_animation_finished():
	if not player_controller:
		return

	var current = animated_sprite.animation
	print("✅ 动画播放结束:", current)

	if current == attack_animation_name:
		player_controller.on_attack_animation_finished()
	elif current == "hurt":
		player_controller.on_hurt_animation_finished()

# 特效播放结束（Godot4 bind sender）
func _on_attack_effect_finished(sprite: AnimatedSprite2D):
	if sprite:
		sprite.visible = false

func _process(_delta):
	if not player_controller:
		return
		
	# ===========================
	#      新增：UI 模式的最高优先级
	# ===========================
	if player_controller.is_in_ui_mode:
		animated_sprite.play("idle")
		return # 如果在UI模式，直接播放idle并跳过后续所有逻辑

	# 优先级：受伤 > 攻击 > 其他动作
	if player_controller.is_hurt:
		return
	elif player_controller.is_attacking:
		return # 正在攻击时不切换

	# 翻转
	if player_controller.direction == 1:
		animated_sprite.flip_h = false
		if attackM: attackM.flip_h = false
		if attackE: attackE.flip_h = false
		if attack_area:
			attack_area.scale.x = 1
	elif player_controller.direction == -1:
		animated_sprite.flip_h = true
		if attackM: attackM.flip_h = true
		if attackE: attackE.flip_h = true
		if attack_area:
			attack_area.scale.x = -1

	# 普通动作动画
	var vel = player_controller.velocity
	if not player_controller.is_on_floor():
		if vel.y < 0.0:
			animated_sprite.play("jump")
		elif vel.y > 0.0:
			animated_sprite.play("fall")
	elif abs(vel.x) > 0.1:
		animated_sprite.play("move")
	else:
		animated_sprite.play("idle")

func play_hurt_animation():
	if not animated_sprite:
		return

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("hurt"):
		print("🤕 播放受击动画")
		animated_sprite.animation = "hurt"
		animated_sprite.frame = 0
		animated_sprite.play()
	else:
		print("❌ 找不到 hurt 动画")
