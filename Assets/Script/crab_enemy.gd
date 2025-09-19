extends CharacterBody2D

@export var patrol_points : Node
@export var speed : int = 1500
@export var wait_time : int = 3
@export var damage_to_player : int = 1
@export var max_health := 1
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@onready var damage_area = $DamageArea

@onready var crab_enemy_noise: AudioStreamPlayer2D = $Crab_Enemy_Noise
@onready var crab_enemy_walking: AudioStreamPlayer2D = $Crab_Enemy_Walking

const GRAVITY = 1000

enum State {Idle, Walk}
var current_health := max_health
var current_state :State
var direction : Vector2 = Vector2.LEFT
var number_of_points: int
var point_positions: Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk : bool

func _ready():
	# Add to the "Enemy" group for easy identification
	add_to_group("Enemy")
	
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points")
		
	timer.wait_time = wait_time
	
	current_state = State.Idle
	
	if has_node("DamageArea"):
		$DamageArea.body_entered.connect(_on_damage_area_body_entered)
	
	
func _physics_process(delta : float):
	enemy_gravity(delta)
	match current_state:
		State.Idle:
			enemy_idle(delta)
		State.Walk:
			enemy_walk(delta)
	
	move_and_slide()
	
	enemy_animations()
	
	# Check for collision with the player
	check_player_collision()

func take_damage(amount: int):
	current_health -= amount
	print("💥 Enemy took", amount, "damage. HP:", current_health)

	if current_health <= 0:
		die()

func die():
	print("☠ Enemy died")
	queue_free()

func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta


func enemy_idle(delta : float):
	if !can_walk:
		
		if crab_enemy_walking.is_playing():
			crab_enemy_walking.stop()
		
		if not crab_enemy_noise.is_playing():
			crab_enemy_noise.play()
			
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle


func enemy_walk(delta : float):
	if crab_enemy_noise.is_playing():
		crab_enemy_noise.stop()
		
		if not crab_enemy_walking.is_playing():
			crab_enemy_walking.play()
	
	if !can_walk:
		return
	
	if abs(position.x -current_point.x) > 0.5:
		velocity.x = direction.x * speed * delta
		current_state = State.Walk
	else:
		current_point_position +=1
		
		if current_point_position >= number_of_points:
			current_point_position = 0		
			
		current_point = point_positions[current_point_position]

		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
			
		can_walk = false
		timer.start()
		current_state = State.Idle
	animated_sprite_2d.flip_h = direction.x > 0
	

func enemy_animations():
	if current_state == State.Idle && !can_walk:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk && can_walk:
		animated_sprite_2d.play("walk")
		
# Check for collision with the player
func check_player_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if the colliding object is a player
		if collider.is_in_group("Player"):
			print("Crab touched player! Dealing damage.")
			# Deal damage to the player
			collider.take_damage(damage_to_player, global_position)
			break
			
# Area2D detects a player entering	
func _on_damage_area_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered crab damage area!")
		body.take_damage(damage_to_player, global_position)

func _on_timer_timeout() -> void:
	can_walk = true
	current_state = State.Walk
