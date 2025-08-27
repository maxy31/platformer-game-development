extends Area2D

@export_group("Pathfinding")
@export var detect_area: float = 300
@export var chase_speed: float = 3

@export_group("Base Attribute")
@export var health: int = 4   # 蝙蝠的血量

@onready var player = $"../../RacerController"
@onready var anim_s: AnimatedSprite2D = $AnimatedSprite2D

var players: Array = []

# 🚩 新增变量
var stay_timer: float = 0.0
var is_on_player_head: bool = false

func _ready() -> void:
	add_to_group("Enemy")

func _process(delta: float) -> void:
	if player:
		var distance = get_manhattan(player.position, position)
		if distance < detect_area:
			anim_s.play("fly")
			var direction = (player.position - Vector2(0, 20) - position).normalized()
			position += direction * chase_speed

	# 🚩 处理停留时间
	if is_on_player_head:
		stay_timer += delta
		if stay_timer >= 3.0:   # 超过 3 秒
			if player and player.has_method("take_damage"):
				player.take_damage(1)  # 玩家扣血 1 点
				print("Player took damage from Bat!")
			stay_timer = 0.0  # 重置计时器
	else:
		stay_timer = 0.0

func get_manhattan(pos1: Vector2, pos2: Vector2) -> float:
	return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		players.append(body)
		# 🚩 检查是不是在玩家头上
		if position.y < body.position.y: 
			is_on_player_head = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		players.erase(body)
		is_on_player_head = false

# 🚩 玩家攻击时调用
func take_damage(damage: int) -> void:
	health -= damage
	print("Bat HP:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Bat died!")
	queue_free()
