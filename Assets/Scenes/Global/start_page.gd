extends Control
@onready var audio_controller = $MiscAudio

func _ready():
	# 游戏启动时加载进度
	GlobalData.load_game()
	print("游戏已启动，当前解锁关卡: ", GlobalData.unlocked_level)
	MusicPlayer.change_music("res://Assets/Audio/BGM/Main_Menu.wav")

func _on_start_button_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	# 重置角色选择
	GlobalData.selected_character = ""
	GlobalData.selected_character_scene_path = ""
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/CharacterSelectScreen.tscn")

func _on_quit_button_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	# 退出前保存游戏
	GlobalData.save_game()
	
	# 删除存档文件（根据您的需求）
	var save_path = "user://save_game.cfg"
	if FileAccess.file_exists(save_path):
		var dir := DirAccess.open("user://")
		if dir != null:
			dir.remove("save_game.cfg")
			print("存档已删除")
	
	get_tree().quit()
