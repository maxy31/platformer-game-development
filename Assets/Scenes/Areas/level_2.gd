extends Node2D

@onready var spawn_point = $PlayerSpawnPoint  # 应该是 Marker2D 节点

func _ready():
	# 生成玩家角色
	_spawn_player()

func _spawn_player():
	# 检查是否有选择的角色
	if GlobalState.selected_character_scene_path.is_empty():
		print("No character selected, using default’")
		# 可以在这里加载默认角色
		GlobalState.selected_character_scene_path = "res://Assets/Scenes/PlayerController/FlymanPlayer.tscn"
	
	# 加载玩家场景
	var character_scene = load(GlobalState.selected_character_scene_path)
	if character_scene:
		var character_instance = character_scene.instantiate()
		add_child(character_instance)
		
		# 设置生成位置
		if spawn_point:
			character_instance.global_position = spawn_point.global_position
			print("Player spawned at position: ", spawn_point.global_position)
		else:
			character_instance.global_position = Vector2(100, 300)
			print("Using default spawn position")
		
		# 确保退出UI模式
		if character_instance.has_method("exit_ui_mode"):
			character_instance.exit_ui_mode()
		
		print("Player spawned successfully: ", character_instance.name)
	else:
		print("Error: Character scene does not exist - ", GlobalState.selected_character_scene_path)
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
	
	# 设置位置
	if spawn_point:
		player.global_position = spawn_point.global_position
	else:
		player.global_position = Vector2(100, 300)
	
	add_child(player)
	print("Fallback player created")
