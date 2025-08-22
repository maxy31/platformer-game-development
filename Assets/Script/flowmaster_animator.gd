extends Node2D
class_name FlowmasterAnimator

@export var player_controller: FlowmasterController
@export var animated_sprite: AnimatedSprite2D
@export var attack_area: Area2D

var attack_animation_name := "attack1"  # 攻击动画名称（请和 SpriteFrames 的动画名一致）

func _ready():
	# 只在 ready 时连一次信号
	if animated_sprite:
		animated_sprite.animation_finished.connect(Callable(self, "_on_animation_finished"))

func _process(_delta):
	if not player_controller:
		return

	# 优先级：受伤 > 攻击 > 其他动作
	if player_controller.is_hurt:
		return
	elif player_controller.is_attacking:
		# 正在攻击时不切换到 move/jump/idle，等待动画结束
		return

	# 翻转角色和攻击范围
	if player_controller.direction == 1:
		animated_sprite.flip_h = false
		if attack_area:
			attack_area.scale.x = 1
	elif player_controller.direction == -1:
		animated_sprite.flip_h = true
		if attack_area:
			attack_area.scale.x = -1

	# 运动状态动画（idle/move/jump/fall）
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

func play_attack_animation():
	if not animated_sprite:
		return

	# 如果动画资源里有该动画就切换
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(attack_animation_name):
		print("🎬 播放攻击動畫:", attack_animation_name)

		# ✅ 切换 offset
		animated_sprite.offset.x = 32  

		# 切到该动画并从头开始
		animated_sprite.animation = attack_animation_name
		animated_sprite.frame = 0
		animated_sprite.play()
	else:
		print("❌ 找不到攻击动画:", attack_animation_name)

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

func _on_animation_finished():
	# AnimatedSprite2D 的 animation_finished 不带参数
	if not player_controller:
		return

	var current = animated_sprite.animation
	print("✅ 动画播放结束:", current)

	if current == attack_animation_name:
		# ✅ 攻击动画结束后恢复 offset
		animated_sprite.offset.x = 0  
		player_controller.on_attack_animation_finished()
	elif current == "hurt":
		player_controller.on_hurt_animation_finished()
