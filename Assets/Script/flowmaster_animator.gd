extends Node2D
class_name FlowmasterAnimator

@export var player_controller: FlowmasterController
@export var animated_sprite: AnimatedSprite2D   # Character itself
@export var attackM: AnimatedSprite2D           # MiddleAttackEffect
@export var attackE: AnimatedSprite2D           # EndAttackEffect
@export var attack_area: Area2D

var attack_animation_name := "attack1"

func _ready():
	# Hide effects by default
	if attackM:
		attackM.visible = false
	if attackE:
		attackE.visible = false

	# Normal animation finished
	if animated_sprite:
		animated_sprite.animation_finished.connect(Callable(self, "_on_animation_finished"))

	# Attack effect finished
	if attackM:
		attackM.animation_finished.connect(Callable(self, "_on_attack_effect_finished").bind(attackM))
	if attackE:
		attackE.animation_finished.connect(Callable(self, "_on_attack_effect_finished").bind(attackE))

# Attack animation (character)
func play_attack_animation():
	if not animated_sprite:
		return

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(attack_animation_name):
		print("🎬 Playing attack animation:", attack_animation_name)

		# Play character attack animation
		animated_sprite.animation = attack_animation_name
		animated_sprite.frame = 0
		animated_sprite.play()

		# Play attack effects
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
		print("❌ Attack animation not found:", attack_animation_name)

# Character animation finished playing
func _on_animation_finished():
	if not player_controller:
		return

	var current = animated_sprite.animation
	print("✅ Animation finished playing:", current)

	if current == attack_animation_name:
		player_controller.on_attack_animation_finished()
	elif current == "hurt":
		player_controller.on_hurt_animation_finished()

# Effect finished playing
func _on_attack_effect_finished(sprite: AnimatedSprite2D):
	if sprite:
		sprite.visible = false

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
		return  # Don't switch animation while attacking

	# Flip direction
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

func play_hurt_animation():
	if not animated_sprite:
		return

	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("hurt"):
		print("🤕 Playing hurt animation")
		animated_sprite.animation = "hurt"
		animated_sprite.frame = 0
		animated_sprite.play()
	else:
		print("❌ 'hurt' animation not found")
