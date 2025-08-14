extends Node2D
class_name DestroyerAnimator

@export var player_controller: FlymanController
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D
@export var attack_area: Area2D

func _process(delta):
	if not player_controller:
		return

	var vel = player_controller.velocity

	# 翻转方向 & 攻击区域位置
	if player_controller.direction == 1:
		sprite.flip_h = false
		attack_area.scale.x = 1
	elif player_controller.direction == -1:
		sprite.flip_h = true
		attack_area.scale.x = -1

	# 非攻击状态播放移动/跳跃动画
	if not player_controller.is_attacking:
		if not player_controller.is_on_floor():
			if vel.y < 0.0:
				animation_player.play("jump")
			elif vel.y > 0.0:
				animation_player.play("fall")
		elif abs(vel.x) > 0.1:
			animation_player.play("move")
		else:
			animation_player.play("idle")

func play_attack_animation():
	if animation_player and animation_player.has_animation("attack1"):
		print("🎬 播放攻击动画: attack1")
		animation_player.play("attack1")
	else:
		print("❌ 找不到 attack1 动画，或者 animation_player 没绑定")
