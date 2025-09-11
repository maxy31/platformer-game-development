extends Node2D

@onready var spawn_point = $PlayerSpawnPoint  # 直接获取，不需要路径

func _ready():
	print("=== Level Initialisation ===")
	print("Spawn point exists: ", spawn_point != null)
	if spawn_point:
		print("Spawn point exists: ", spawn_point.global_position)
	else:
		print("Error: PlayerSpawnPoint node not found!")
		print("Nodes in scene: ")
		for child in get_children():
			print(" - ", child.name, " (", child.get_class(), ")")
	
	# 生成玩家
	_spawn_player()

func _spawn_player():
	# 检查生成点
	if not spawn_point:
		print("Critical error: No spawn point found, unable to spawn player")
		# 尝试查找其他可能的生成点
		_find_alternative_spawn_point()
		return
	
	# 检查角色路径
	if GlobalState.selected_character_scene_path.is_empty():
		print("No character selected, using default")
		GlobalState.selected_character_scene_path = "res://Assets/Scenes/PlayerController/FlymanPlayer.tscn"
	
	# 加载玩家场景
	var character_scene = load(GlobalState.selected_character_scene_path)
	if character_scene:
		var character_instance = character_scene.instantiate()
		add_child(character_instance)
		
		# 设置生成位置
		character_instance.global_position = spawn_point.global_position
		print("Player spawned at: ", spawn_point.global_position)
		
		# 退出UI模式
		if character_instance.has_method("exit_ui_mode"):
			character_instance.exit_ui_mode()
		
		print("Player spawned successfully:: ", character_instance.name)
	else:
		print("Error: Character scene does not exist")
		_create_fallback_player()

func _find_alternative_spawn_point():
	# 尝试查找其他可能的生成点
	var possible_spawn_points = []
	
	for child in get_children():
		if "Spawn" in child.name or "Start" in child.name:
			possible_spawn_points.append(child)
		elif child is Marker2D:
			possible_spawn_points.append(child)
	
	if possible_spawn_points.size() > 0:
		spawn_point = possible_spawn_points[0]
		print("Found fallback spawn point: ", spawn_point.name)
		_spawn_player()
	else:
		print("No spawn points found, using default position")
		_create_fallback_player()

func _create_fallback_player():
	# 创建备用玩家
	var player = CharacterBody2D.new()
	player.name = "FallbackPlayer"
	
	# 添加碰撞体
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 50)
	collision.shape = shape
	
	# 添加精灵
	var sprite = Sprite2D.new()
	sprite.modulate = Color.RED
	
	player.add_child(collision)
	player.add_child(sprite)
	
	# 设置位置（场景中心或默认位置）
	player.global_position = Vector2(500, 300)
	print("Using default spawn position: ", player.global_position)
	
	add_child(player)
