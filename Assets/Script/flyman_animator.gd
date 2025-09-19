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

	# UI mode has the highest priority
	if player_controller.is_in_ui_mode:
		animation_player.play("idle")
		return # If in UI mode, play idle and skip all subsequent logic

	var vel = player_controller.velocity

	# Prioritize playing the hurt animation
	if player_controller.is_hurt:
		if animation_player and animation_player.has_animation("hurt"):
			if not animation_player.is_playing() or animation_player.current_animation != "hurt":
				print("🤕 Play hurt animation (triggers only once)")
				animation_player.play("hurt")
		return  # Currently being hurt → Don't switch to other animations

	# If currently attacking, don't override the animation
	if player_controller.is_attacking:
		return

	# Normal move/jump animations
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

# Combat & Animation Events
func play_attack_animation(index: int):
	var anim_name = "attack%d" % index
	if animation_player and animation_player.has_animation(anim_name):
		print("🎬 Playing attack animation:", anim_name)
		animation_player.play(anim_name)
	else:
		print("❌ Animation not found", anim_name)

func play_hurt_animation():
	if animation_player and animation_player.has_animation("hurt"):
		print("🤕 Playing hurt animation (called by Player)")
		animation_player.play("hurt")

func _on_animation_finished(anim_name: String):
	print("✅ Animation finished playing:", anim_name)
	if anim_name == "hurt":
		if player_controller:
			player_controller.on_hurt_animation_finished()
	elif anim_name.begins_with("attack"):
		if player_controller:
			player_controller.on_attack_animation_finished()

# This method is called by an animation event (cancel point)
func animation_cancel_point():
	if player_controller:
		player_controller.on_attack_cancel_point()
