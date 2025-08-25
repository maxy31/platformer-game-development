extends Area2D

@export var speed: float = 80
@export var maximum_distance: float = 800.0
@export var damage_percent: float = 1.0
@export var tracking_strength: float = 2.0

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

var direction: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var player: Node2D  # 添加玩家引用

func _ready():
	# 获取玩家引用
	player = get_tree().get_first_node_in_group("Player")
	
	if player:
		direction = (player.global_position - global_position).normalized()
	else:
		# 如果没有找到玩家，使用默认方向
		direction = Vector2.RIGHT
	
	start_position = global_position
	
	rotation = direction.angle()
	
	animation_player.play("create")
	await animation_player.animation_finished
	animation_player.play("fly")
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	var distance_traveled = start_position.distance_to(global_position)
	if distance_traveled >= maximum_distance:
		animation_player.play("explode")
		direction = Vector2.ZERO


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("take_damage"):
		# 使用固定伤害值而不是百分比
		var fixed_damage = 1.0
		body.take_damage(fixed_damage)
		animation_player.play("explode")
		direction = Vector2.ZERO			
