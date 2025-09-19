extends Node

# Stores the player's selected character type and scene path
var selected_character: String = ""
var selected_character_scene_path: String = ""

# Stores the unlocked level progress
var unlocked_level: int = 1

# Save game progress
func save_game():
	var config = ConfigFile.new()
	config.set_value("Progress", "unlocked_level", unlocked_level)
	
	# Save character unlock status
	config.set_value("Characters", "Destroyer_unlocked", false)  # Modify according to the actual unlock status
	config.set_value("Characters", "Racer_unlocked", false)
	config.set_value("Characters", "Flowmaster_unlocked", false)
	
	config.save("user://save_game.cfg")
	print("Game saved")

# Load game progress
func load_game():
	var config = ConfigFile.new()
	if config.load("user://save_game.cfg") == OK:
		if config.has_section_key("Progress", "unlocked_level"):
			unlocked_level = config.get_value("Progress", "unlocked_level", 1)
			print("Game progress loaded: Unlocked up to level ", unlocked_level)
