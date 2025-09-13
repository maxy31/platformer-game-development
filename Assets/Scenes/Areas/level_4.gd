# level4.gd
extends Node2D

@onready var spawn_point = $PlayerSpawnPoint

func _ready():
	
	#Code for lvl 4 BGM
	MusicPlayer.change_music("res://Assets/Audio/BGM/Level_4.ogg")

	print("=== Level 4 Loaded ===")
	print("Selected Character: ", GlobalData.selected_character)
	print("Player will spawn at: ", spawn_point.position)
	
	# 生成玩家
	_spawn_player()
	
	# 调试信息
	_print_scene_info()

func _spawn_player():
	# 检查是否有选择的角色
	if GlobalData.selected_character_scene_path.is_empty():
		print("Warning: No character selected, using default Flyman")
		GlobalData.selected_character_scene_path = "res://Assets/Scenes/PlayerController/FlymanPlayer.tscn"
		GlobalData.selected_character = "Flyman"
	
	# 加载玩家场景
	if ResourceLoader.exists(GlobalData.selected_character_scene_path):
		var character_scene = load(GlobalData.selected_character_scene_path)
		var player_instance = character_scene.instantiate()
		
		# 设置生成位置
		player_instance.position = spawn_point.position
		add_child(player_instance)
		
		print("✅ Player spawned successfully: ", GlobalData.selected_character)
		print("Player position: ", player_instance.position)
	else:
		print("❌ Error: Character scene not found - ", GlobalData.selected_character_scene_path)
		# 创建简单备用玩家
		_create_fallback_player()

func _create_fallback_player():
	# 简单备用玩家
	var player = CharacterBody2D.new()
	player.name = "FallbackPlayer"
	player.add_to_group("Player")  # 重要：添加到Player组
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 50)
	collision.shape = shape
	
	var sprite = Sprite2D.new()
	sprite.modulate = Color.RED  # 红色以便识别
	
	player.add_child(collision)
	player.add_child(sprite)
	player.position = spawn_point.position
	
	add_child(player)
	print("⚠️ Fallback player created")

func _print_scene_info():
	print("=== Scene Node Info ===")
	print("Player spawn point position: ", spawn_point.position)
	
	# 检查飞魔敌人
	if has_node("flying_demon"):
		var demon = $flying_demon
		print("Flying demon position: ", demon.position)
	else:
		print("❌ Flying demon enemy not found")
	
	# 检查是否有玩家节点
	var players = get_tree().get_nodes_in_group("Player")
	print("Number of players in scene: ", players.size())
	for player in players:
		print("Player node: ", player.name, " Position: ", player.position)
