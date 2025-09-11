# level4.gd
extends Node2D

@onready var spawn_point = $PlayerSpawnPoint

func _ready():
	print("=== 关卡4加载完成 ===")
	print("选择的角色: ", GlobalData.selected_character)
	print("玩家将生成在: ", spawn_point.position)
	
	# 生成玩家
	_spawn_player()
	
	# 调试信息
	_print_scene_info()

func _spawn_player():
	# 检查是否有选择的角色
	if GlobalData.selected_character_scene_path.is_empty():
		print("警告：没有选择角色，使用默认Flyman")
		GlobalData.selected_character_scene_path = "res://Assets/Scenes/PlayerController/FlymanPlayer.tscn"
		GlobalData.selected_character = "Flyman"
	
	# 加载玩家场景
	if ResourceLoader.exists(GlobalData.selected_character_scene_path):
		var character_scene = load(GlobalData.selected_character_scene_path)
		var player_instance = character_scene.instantiate()
		
		# 设置生成位置
		player_instance.position = spawn_point.position
		add_child(player_instance)
		
		print("✅ 玩家生成成功: ", GlobalData.selected_character)
		print("玩家位置: ", player_instance.position)
	else:
		print("❌ 错误：角色场景不存在 - ", GlobalData.selected_character_scene_path)
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
	print("⚠️ 已创建备用玩家")

func _print_scene_info():
	print("=== 场景节点信息 ===")
	print("玩家生成点位置: ", spawn_point.position)
	
	# 检查飞魔敌人
	if has_node("flying_demon"):
		var demon = $flying_demon
		print("飞魔位置: ", demon.position)
	else:
		print("❌ 飞魔敌人不存在")
	
	# 检查是否有玩家节点
	var players = get_tree().get_nodes_in_group("Player")
	print("场景中玩家数量: ", players.size())
	for player in players:
		print("玩家节点: ", player.name, " 位置: ", player.position)

# 可选：添加一个测试按钮
func _input(event):
	if event.is_action_pressed("ui_test"):  # 比如按T键测试
		print("=== 手动测试 ===")
		_print_scene_info()
