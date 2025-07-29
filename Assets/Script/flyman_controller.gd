extends CharacterBody2D

class_name FlymanController

@export var speed = 10.0
@export var jump_power = 10.0

# --- 血量与攻击力设置 ---
@export var max_health := 5
var current_health := max_health
@export var attack_damage := 1

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

# --- 受伤逻辑 ---
func take_damage(amount: int = 1):
	current_health -= amount
	print("Player took damage. Current HP:", current_health)
	if current_health <= 0:
		die()

func die():
	print("Player Died")
	queue_free()  # 或触发 Game Over 场景
