# GlobalData.gd
extends Node

# 存储玩家选择的角色类型和场景路径
var selected_character: String = ""
var selected_character_scene_path: String = ""

# 存储解锁的关卡进度
var unlocked_level: int = 1

# 保存游戏进度
func save_game():
	var config = ConfigFile.new()
	config.set_value("Progress", "unlocked_level", unlocked_level)
	
	# 保存角色解锁状态
	config.set_value("Characters", "Destroyer_unlocked", false)  # 根据实际解锁状态修改
	config.set_value("Characters", "Racer_unlocked", false)
	config.set_value("Characters", "Flowmaster_unlocked", false)
	
	config.save("user://save_game.cfg")
	print("游戏已保存")

# 加载游戏进度
func load_game():
	var config = ConfigFile.new()
	if config.load("user://save_game.cfg") == OK:
		if config.has_section_key("Progress", "unlocked_level"):
			unlocked_level = config.get_value("Progress", "unlocked_level", 1)
			print("游戏进度已加载：解锁到关卡", unlocked_level)
