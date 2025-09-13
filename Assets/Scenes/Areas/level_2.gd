extends Node2D

@onready var spawn_point = $PlayerSpawnPoint  # 应该是 Marker2D 节点

func _ready():
	# 生成玩家角色
	_spawn_player()

func _spawn_player():
	if GlobalData.selected_character_scene_path.is_empty():
		print("No character selected, using default Flyman")
		GlobalData.selected_character_scene_path = "res://Assets/Scenes/PlayerController/FlymanPlayer.tscn"
		GlobalData.selected_character = "Flyman"
	
	var character_scene = load(GlobalData.selected_character_scene_path)
	if character_scene:
		var player_instance = character_scene.instantiate()

		# Set spawn position
		if spawn_point:
			player_instance.position = spawn_point.position
		else:
			player_instance.position = Vector2(100, 300)
		
		add_child(player_instance)

		# ✅ Connect player death → GameOverUI
# ✅ Connect player death → GameOverUI
		if player_instance.has_signal("player_died"):
			var ui = $GameOverUI   # path to your UI node
			print("📡 Connecting player_died to GameOverUI:", ui)
			player_instance.player_died.connect(ui.show_game_over)

		if player_instance.has_method("exit_ui_mode"):
			player_instance.exit_ui_mode()
	else:
		print("Error: Character scene does not exist")
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
