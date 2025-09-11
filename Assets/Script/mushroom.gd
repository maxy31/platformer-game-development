extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
	TAKE_HIT,
	DEATH
}

var current_state: State = State.IDLE
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation_player = $AnimationPlayer  # 用于攻击动画
@onready var animated_sprite = $AnimatedSprite2D  # 用于其他状态动画

var max_health: int = 3
var current_health: int = max_health
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
		State.ATTACK:
			attack_state()
		State.TAKE_HIT:
			take_hit_state()
		State.DEATH:
			death_state()

func _on_attack_range_body_entered(body: Node2D) -> void:
	print("检测到: ", body.name, " 组: ", body.get_groups())
	
	if body.is_in_group("Player"):
		player_in_range = true
		player_ref = body
		print("玩家进入攻击范围")

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_ref = null
		print("玩家离开攻击范围")

func idle_state() -> void:
	animated_sprite.play("Idle")  # 使用 AnimatedSprite2D

func attack_state() -> void:
	animation_player.play("Attack")  # 使用 AnimationPlayer
	
	# 攻击逻辑
	if player_ref and player_ref.has_method("take_damage"):
		player_ref.take_damage(1)
		print("Mushroom attacked player!")
	
	# 等待AnimationPlayer动画结束
	await animation_player.animation_finished
	change_state(State.IDLE)

func take_hit_state() -> void:
	animated_sprite.play("TakeHit")  # 使用 AnimatedSprite2D
	await animated_sprite.animation_finished
	
	if current_health <= 0:
		change_state(State.DEATH)
	else:
		change_state(State.IDLE)

func death_state() -> void:
	animated_sprite.play("Death")  # 使用 AnimatedSprite2D
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
