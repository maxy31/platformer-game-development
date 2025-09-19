extends Control
@onready var audio_controller = $MiscAudio

func _ready():
	# Load progress when the game starts
	GlobalData.load_game()
	print("Game started, currently unlocked level: ", GlobalData.unlocked_level)
	MusicPlayer.change_music("res://Assets/Audio/BGM/Main_Menu.wav")

func _on_start_button_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	# Reset character selection
	GlobalData.selected_character = ""
	GlobalData.selected_character_scene_path = ""
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/CharacterSelectScreen.tscn")

func _on_quit_button_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	# Save the game before quitting
	GlobalData.save_game()
	
	# Delete the save file
	var save_path = "user://save_game.cfg"
	if FileAccess.file_exists(save_path):
		var dir := DirAccess.open("user://")
		if dir != null:
			dir.remove("save_game.cfg")
			print("Save file deleted")
	
	get_tree().quit()
