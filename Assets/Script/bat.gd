extends Area2D

@export_group("Pathfinding")
@export var detect_area: float = 300
@export var chase_speed: float = 3
@export var stop_distance: float = 10 # Minimum distance at which the bat stops chasing

@export_group("Base Attribute")
@export var health: int = 4  # Bat's health

@onready var anim_s: AnimatedSprite2D = $AnimatedSprite2D

var players: Array = []  # Stores all detected players
var stay_timer: float = 0.0
var is_on_player_head: bool = false
var is_chasing: bool = false # Used to track if the bat is currently chasing

func _ready() -> void:
	add_to_group("Enemy")

func _process(delta: float) -> void:
	var was_chasing = is_chasing # Store the chasing state from the previous frame
	is_chasing = false

	if players.size() > 0:
		var target_player = get_closest_player()
		if target_player:
			var distance = get_manhattan(target_player.position, position)
			
			if distance < detect_area and distance > stop_distance:
				is_chasing = true
				var direction = (target_player.position - position).normalized()
				position += direction * chase_speed
			
	# Control animation based on chasing state
	if is_chasing:
		if not was_chasing:
			anim_s.play("fly")
	else:
		anim_s.play("fly")

	# Handle stay time
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

# Manhattan distance calculation
func get_manhattan(pos1: Vector2, pos2: Vector2) -> float:
	return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

# Find the closest player
func get_closest_player() -> Node2D:
	var closest_player: Node2D = null
	var min_distance = INF
	for p in players:
		var dist = get_manhattan(p.position, position)
		if dist < min_distance:
			min_distance = dist
			closest_player = p
	return closest_player

# When player enters the main bat's collision area
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if position.y < body.position.y:
			is_on_player_head = true

# When a player leaves the main bat's collision area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_on_player_head = false

# When a player enters the [DetectionArea]'s detection range
func _on_DetectionArea_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not players.has(body):
			players.append(body)

# When a player leaves the [DetectionArea]'s detection range
func _on_DetectionArea_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if players.has(body):
			players.erase(body)

# Called when the player attacks
func take_damage(damage: int) -> void:
	health -= damage
	print("Bat HP:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Bat died!")
	queue_free()
