extends Node2D
class_name RacerAnimator

@export var player_controller: RacerController
@export var animated_sprite: AnimatedSprite2D
@export var attack_area: Area2D

var attack_animation_name := "attack1"  # Attack animation name

func _ready():
	# Only connect the signal once in _ready
	if animated_sprite:
		animated_sprite.animation_finished.connect(Callable(self, "_on_animation_finished"))

func _process(_delta):
	if not player_controller:
		return
		
	# UI mode has the highest priority
	if player_controller.is_in_ui_mode:
		animated_sprite.play("idle")
		return # If in UI mode, play idle and skip all subsequent logic


	# Priority: Hurt > Attack > Other actions
	if player_controller.is_hurt:
		return
	elif player_controller.is_attacking:
		# Don't switch animation while attacking
		return

	# Flip direction
	if player_controller.direction == 1:
		animated_sprite.flip_h = false
		if attack_area:
			attack_area.scale.x = 1
	elif player_controller.direction == -1:
		animated_sprite.flip_h = true
		if attack_area:
			attack_area.scale.x = -1

	# Normal action animations
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

	# Change to correct animation if available
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(attack_animation_name):
		print("🎬 Playing attaack animation:", attack_animation_name)
		# Change and start from said animation
		animated_sprite.animation = attack_animation_name
		animated_sprite.frame = 0
		animated_sprite.play()
	else:
		print("❌ No attack animation found:", attack_animation_name)

func play_hurt_animation():
	if not animated_sprite:
		return

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("hurt"):
		print("🤕 Play hurt animation")
		animated_sprite.animation = "hurt"
		animated_sprite.frame = 0
		animated_sprite.play()
	else:
		print("❌ No hurt animation found")

func _on_animation_finished():
	# The animation_finished signal from AnimatedSprite2D does not have parameters
	if not player_controller:
		return

	var current = animated_sprite.animation
	print("✅ Animation playing finished:", current)
	if current == attack_animation_name:
		player_controller.on_attack_animation_finished()
	elif current == "hurt":
		player_controller.on_hurt_animation_finished()
