extends Node2D
class_name FlymanAnimator

@export var player_controller: FlymanController
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D
@export var attack_area: Area2D

func _ready():
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)

func _process(delta):
	if not player_controller:
		return

	var vel = player_controller.velocity

	# 如果正在攻击，就不要随便覆盖动画
	if player_controller.is_attacking:
		return

	if player_controller.direction == 1:
		sprite.flip_h = false
		attack_area.scale.x = 1
	elif player_controller.direction == -1:
		sprite.flip_h = true
		attack_area.scale.x = -1

	if not player_controller.is_on_floor():
		if vel.y < 0.0:
			animation_player.play("jump")
		elif vel.y > 0.0:
			animation_player.play("fall")
	elif abs(vel.x) > 0.1:
		animation_player.play("move")
	else:
		animation_player.play("idle")

func play_attack_animation(index: int):
	var anim_name = "attack%d" % index
	if animation_player and animation_player.has_animation(anim_name):
		print("🎬 播放攻击动画:", anim_name)
		animation_player.play(anim_name)
	else:
		print("❌ 找不到动画", anim_name)

func _on_animation_finished(anim_name: String):
	print("✅ 动画播放结束:", anim_name)
	if anim_name.begins_with("attack"):
		if player_controller:
			player_controller.on_attack_animation_finished()

# 这个方法会在动画事件中调用
func animation_cancel_point():
	if player_controller:
		player_controller.on_attack_cancel_point()
