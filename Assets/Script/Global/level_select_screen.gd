extends Control

@onready var level1_button = $Level1
@onready var level2_button = $Level2
@onready var level3_button = $Level3
@onready var level4_button = $Level4
@onready var audio_controller = $MiscAudio

func _ready():
	# Using GlobalData to load game progress
	GlobalData.load_game()
	
	var unlocked_level = GlobalData.unlocked_level
	
	# Activate / access buttons
	level1_button.disabled = false
	level2_button.disabled = unlocked_level < 2
	level3_button.disabled = unlocked_level < 3
	level4_button.disabled = unlocked_level < 4
	
	# Show current selected character
	print("Current selected character: ", GlobalData.selected_character)
	print("Character scene path: ", GlobalData.selected_character_scene_path)

func _on_level_1_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	get_tree().change_scene_to_file("res://Assets/Scenes/Level/level1.tscn")

func _on_level_2_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	get_tree().change_scene_to_file("res://Assets/Scenes/Level/level2.tscn")

func _on_level_3_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	get_tree().change_scene_to_file("res://Assets/Scenes/Level/level3.tscn")

func _on_level_4_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	get_tree().change_scene_to_file("res://Assets/Scenes/Level/level4.tscn")

func _on_back_pressed() -> void:
	print("Button sound invoked")
	audio_controller.play_button_click()
	await audio_controller.audio_button_click.finished
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/start_page.tscn")
