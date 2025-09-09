extends Control

@onready var level1_button = $Level1
@onready var level2_button = $Level2
@onready var level3_button = $Level3

func _ready():
	var save_path = "user://save_game.cfg"
	print(save_path)
	var config = ConfigFile.new()
	var unlocked_level = 1  # default to level 1 only

	if config.load(save_path) == OK:
		if config.has_section_key("Progress", "unlocked_level"):
			unlocked_level = config.get_value("Progress", "unlocked_level", 1)

	# Enable buttons accordingly
	level1_button.disabled = false
	level2_button.disabled = unlocked_level < 2
	level3_button.disabled = unlocked_level < 3
	
func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/level1.tscn")

func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/level2.tscn")

func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/level3.tscn")
