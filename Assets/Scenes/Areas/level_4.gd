# level4.gd
extends Node2D

@onready var spawn_point = $PlayerSpawnPoint

func _ready():
	print("=== Level 4 Loaded ===")
	print("Selected Character: ", GlobalData.selected_character)
	print("Player will spawn at: ", spawn_point.position)
	
	# 生成玩家
	_spawn_player()
	
	# 调试信息
	_print_scene_info()

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
