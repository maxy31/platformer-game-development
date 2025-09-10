extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/CharacterSelectScreen.tscn")

func _on_quit_button_pressed() -> void:
		# Path to your save file
	var save_path = "user://save_game.cfg"

	# Delete the save file if it exists
	if FileAccess.file_exists(save_path):
		var dir := DirAccess.open("user://")
		if dir != null:
			dir.remove("save_game.cfg")
			print("Save data deleted.")
			
	get_tree().quit()
