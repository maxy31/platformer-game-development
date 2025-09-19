extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
	TAKE_HIT,
	DEATH
}

var current_state: State = State.IDLE
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation_player = $AnimationPlayer  # For the attack animation
@onready var animated_sprite = $AnimatedSprite2D  # For other state animations
@onready var crab_enemy_noise: AudioStreamPlayer2D = $Crab_Enemy_Noise

var max_health: int = 3
var current_health: int = 6
var player_in_range: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	change_state(State.IDLE)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
	
	if player_in_range and current_state == State.IDLE:
		change_state(State.ATTACK)

func change_state(new_state: State) -> void:
	if current_state == State.DEATH:
		return
	current_state = new_state
	
	match current_state:
		State.IDLE:
			idle_state()
			crab_enemy_noise.play()
		State.ATTACK:
			attack_state()
		State.TAKE_HIT:
			take_hit_state()
		State.DEATH:
			death_state()

func _on_attack_range_body_entered(body: Node2D) -> void:
	print("Detected: ", body.name, " Group: ", body.get_groups())
	
	if body.is_in_group("Player"):
		player_in_range = true
		player_ref = body
		print("Player entered attack range")

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_ref = null
		print("Player left attack range")

func idle_state() -> void:
	animated_sprite.play("Idle") # Use AnimatedSprite2D

func attack_state() -> void:
	animation_player.play("Attack") # Use AnimationPlayer
	
	# Attack logic
	if player_ref and player_ref.has_method("take_damage"):
		player_ref.take_damage(1)
		print("Mushroom attacked player!")
	
	# Wait for the AnimationPlayer animation to finish
	await animation_player.animation_finished
	change_state(State.IDLE)

func take_hit_state() -> void:
	animated_sprite.play("TakeHit") # Use AnimatedSprite2D
	await animated_sprite.animation_finished
	
	if current_health <= 0:
		change_state(State.DEATH)
	else:
		change_state(State.IDLE)

func death_state() -> void:
	animated_sprite.play("Death")  # Use AnimatedSprite2D
	await animated_sprite.animation_finished
	queue_free()

func take_damage(damage_amount: int) -> void:
	current_health -= damage_amount
	print("Mushroom took ", damage_amount, " damage! Health: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()
	else:
		change_state(State.TAKE_HIT)

func die() -> void:
	change_state(State.DEATH)
