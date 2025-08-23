extends Node2D
class_name FlowmasterAnimator

@export var player_controller: FlowmasterController
@export var animated_sprite: AnimatedSprite2D
@export var attack_animated_sprite: AnimatedSprite2D
@export var attack_area: Area2D

var attack_animation_name := "attack1"  # 攻击动画名称

func _ready():
	# 普通动画的信号
	if animated_sprite:
		animated_sprite.animation_finished.connect(Callable(self, "_on_animation_finished"))

	# 攻击动画的信号
	if attack_animated_sprite:
		attack_animated_sprite.animation_finished.connect(Callable(self, "_on_attack_animation_finished"))

func _process(_delta):
	if not player_controller:
		return

	# 优先级：受伤 > 攻击 > 其他动作
	if player_controller.is_hurt:
		return
	elif player_controller.is_attacking:
		return # 正在攻击时不切换

	# 翻转
	if player_controller.direction == 1:
		animated_sprite.flip_h = false
		attack_animated_sprite.flip_h = false
		if attack_area:
			attack_area.scale.x = 1
	elif player_controller.direction == -1:
		animated_sprite.flip_h = true
		attack_animated_sprite.flip_h = true
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

func play_attack_animation():
	if not attack_animated_sprite:
		return

	if attack_animated_sprite.sprite_frames and attack_animated_sprite.sprite_frames.has_animation(attack_animation_name):
		print("🎬 播放攻击動畫:", attack_animation_name)

		# 切换显示
		animated_sprite.visible = false
		attack_animated_sprite.visible = true

		# 从头播放攻击动画
		attack_animated_sprite.animation = attack_animation_name
		attack_animated_sprite.frame = 0
		attack_animated_sprite.play()
	else:
		print("❌ 找不到攻击动画:", attack_animation_name)

func _on_attack_animation_finished():
	if attack_animated_sprite.animation == attack_animation_name:
		print("✅ 攻击动画结束，切回普通动画")
		attack_animated_sprite.visible = false
		animated_sprite.visible = true
		player_controller.on_attack_animation_finished()

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
	if not player_controller:
		return

	var current = animated_sprite.animation
	print("✅ 动画播放结束:", current)

	if current == "hurt":
		player_controller.on_hurt_animation_finished()
