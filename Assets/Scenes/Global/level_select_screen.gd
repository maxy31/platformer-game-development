extends Control

@onready var level1_button = $Level1
@onready var level2_button = $Level2
@onready var level3_button = $Level3
@onready var level4_button = $Level4

func _ready():
	# 使用 GlobalData 加载游戏进度
	GlobalData.load_game()
	
	var unlocked_level = GlobalData.unlocked_level
	
	# 启用按钮
	level1_button.disabled = false
	level2_button.disabled = unlocked_level < 2
	level3_button.disabled = unlocked_level < 3
	level4_button.disabled = unlocked_level < 4
	
	# 显示选择的角色
	print("当前选择角色: ", GlobalData.selected_character)
	print("角色场景路径: ", GlobalData.selected_character_scene_path)

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/level1.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/level2.tscn")

func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/level3.tscn")

func _on_level_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/level4.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/start_page.tscn")
