extends Node2D

@onready var spawn_point = $PlayerSpawnPoint  # 确保场景中有这个节点

func _ready():
	# 生成玩家角色
	_spawn_player()

func _spawn_player():
	# 检查是否有选择的角色
	if GlobalData.selected_character_scene_path.is_empty():
		print("没有选择角色，使用默认Flyman")
		GlobalData.selected_character_scene_path = "res://Assets/Scenes/PlayerController/FlymanPlayer.tscn"
		GlobalData.selected_character = "Flyman"
	
	# 加载玩家场景
	var character_scene = load(GlobalData.selected_character_scene_path)
	if character_scene:
		var player_instance = character_scene.instantiate()
		
		# 设置生成位置
		if spawn_point:
			player_instance.position = spawn_point.position
		else:
			# 如果没有生成点，使用默认位置
			player_instance.position = Vector2(100, 300)
		
		add_child(player_instance)
		
		# 确保退出UI模式（如果角色有这个方法）
		if player_instance.has_method("exit_ui_mode"):
			player_instance.exit_ui_mode()
	else:
		print("错误：角色场景不存在")
		# 创建备用玩家
		_create_fallback_player()

func _create_fallback_player():
	# 创建一个简单的玩家节点作为备用
	var player = CharacterBody2D.new()
	player.name = "FallbackPlayer"
	
	# 添加碰撞体
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 50)
	collision.shape = shape
	
	# 添加精灵
	var sprite = Sprite2D.new()
	sprite.modulate = Color.RED  # 红色以便识别
	
	player.add_child(collision)
	player.add_child(sprite)
	
	# 设置位置
	if spawn_point:
		player.position = spawn_point.position
	else:
		player.position = Vector2(100, 300)
	
	add_child(player)
