extends Area2D

@export_group("Pathfinding")
@export var detect_area: float = 300
@export var chase_speed: float = 3
@export var stop_distance: float = 10 # 蝙蝠停止追逐的最小距离

@export_group("Base Attribute")
@export var health: int = 4  # 蝙蝠的血量

@onready var anim_s: AnimatedSprite2D = $AnimatedSprite2D

var players: Array = []  # 存储检测到的所有玩家
var stay_timer: float = 0.0
var is_on_player_head: bool = false
var is_chasing: bool = false # 用于追踪蝙蝠是否正在追逐

func _ready() -> void:
	add_to_group("Enemy")

func _process(delta: float) -> void:
	var was_chasing = is_chasing # 保存上一帧的追逐状态
	is_chasing = false

	if players.size() > 0:
		var target_player = get_closest_player()
		if target_player:
			var distance = get_manhattan(target_player.position, position)
			
			if distance < detect_area and distance > stop_distance:
				is_chasing = true
				var direction = (target_player.position - position).normalized()
				position += direction * chase_speed
			
	# 根据追逐状态控制动画
	if is_chasing:
		if not was_chasing:
			anim_s.play("fly")
	else:
		anim_s.play("fly")

	# 处理停留时间
	if is_on_player_head:
		stay_timer += delta
		if stay_timer >= 3.0:
			if players.size() > 0:
				for p in players:
					if p.has_method("take_damage"):
						p.take_damage(1)
						print("Player took damage from Bat!")
			stay_timer = 2.0
	else:
		stay_timer = 0.0

# 曼哈顿距离计算
func get_manhattan(pos1: Vector2, pos2: Vector2) -> float:
	return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

# 找到最近的玩家
func get_closest_player() -> Node2D:
	var closest_player: Node2D = null
	var min_distance = INF
	for p in players:
		var dist = get_manhattan(p.position, position)
		if dist < min_distance:
			min_distance = dist
			closest_player = p
	return closest_player

# 当玩家进入主蝙蝠的碰撞范围
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if position.y < body.position.y:
			is_on_player_head = true

# 当玩家离开主蝙蝠的碰撞范围
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_on_player_head = false

# 当玩家进入【DetectionArea】的侦测范围
func _on_DetectionArea_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not players.has(body):
			players.append(body)

# 当玩家离开【DetectionArea】的侦测范围
func _on_DetectionArea_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if players.has(body):
			players.erase(body)

# 玩家攻击时调用
func take_damage(damage: int) -> void:
	health -= damage
	print("Bat HP:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Bat died!")
	queue_free()
