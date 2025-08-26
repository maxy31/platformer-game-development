extends Area2D

@export_group("Pathfinding")
@export var detect_area: float = 300
@export var chase_speed: float = 3

@export_group("Base Attribute")
@export var health: int = 4   # 蝙蝠的血量

@onready var player = $"../../RacerController"
@onready var anim_s: AnimatedSprite2D = $AnimatedSprite2D

var players: Array = []

func _ready() -> void:
	add_to_group("Enemy")

func _process(delta: float) -> void:
	if player:
		var distance = get_manhattan(player.position, position)
		if distance < detect_area:
			anim_s.play("fly")
			var direction = (player.position - Vector2(0, 20) - position).normalized()
			position += direction * chase_speed

func get_manhattan(pos1: Vector2, pos2: Vector2) -> float:
	return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		players.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		players.erase(body)

# 🚩 玩家攻击时调用
func take_damage(damage: int) -> void:
	health -= 1
	print("Bat HP:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Bat died!")
	queue_free()
