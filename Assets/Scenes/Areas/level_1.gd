extends Node2D

@onready var spawn_point: Node2D = $SpawnPoint  # Make sure this exists in your level

func _ready():
	var character_path = GlobalState.selected_character_scene_path
	
	#Code for lvl 1 BGM
	MusicPlayer.change_music("res://Assets/Audio/BGM/Level_1.mp3")
	
	if character_path == "":
		print("No character selected! Using default.")
		return  # Or load a default character

	var character_scene = load(character_path)
	if not character_scene:
		print("Failed to load character from: ", character_path)
		return

	var character_instance = character_scene.instantiate()
	add_child(character_instance)
	character_instance.global_position = spawn_point.global_position

	# Ensure UI mode is turned off for gameplay
	if character_instance.has_method("exit_ui_mode"):
		character_instance.exit_ui_mode()
