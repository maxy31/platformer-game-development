extends Control

# IMPORTANT: Changed from 'const' to 'var' to allow modification at runtime.
var CHARACTERS_DATA = {
	"Flyman": {
		"name": "Flyman",
		"description": "The origin of all things, the pioneer of stories.",
		"texture_path": "res://assets/sprites/knight_display.png",
		"scene_path": "res://Assets/Scenes/PlayerController/FlymanPlayer.tscn",
		"locked": false
	},
	"Destroyer": {
		"name": "Destroyer",
		"description": "The Mighty Assassin.",
		"texture_path": "res://assets/sprites/wizard_display.png",
		"scene_path": "res://Assets/Scenes/PlayerController/DestroyerPlayer.tscn",
		"locked": true # Default locked status
	},
	"Racer": {
		"name": "Racer",
		"description": "Noble Knight, Master of Speed.",
		"texture_path": "res://assets/sprites/rogue_display.png",
		"scene_path": "res://Assets/Scenes/PlayerController/RacerPlayer.tscn",
		"locked": true # Default locked status
	},
	"Flowmaster": {
		"name": "Flowmaster",
		"description": "The Omniscient and Omnipotent Mage.",
		"texture_path": "res://assets/sprites/rogue_display.png",
		"scene_path": "res://Assets/Scenes/PlayerController/FlowmasterPlayer.tscn",
		"locked": true # Default locked status
	}
}

# Array to hold the keys for easy indexing
var character_keys: Array = []
var current_character_index: int = 0

# UI Node references
@onready var character_viewport: SubViewport = $MarginContainer/VBoxContainer/HBoxContainer/CharacterDisplayPanel/SubViewportContainer/CharacterViewport
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var next_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/NextButton
@onready var previous_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/PreviousButton
@onready var select_button: Button = $MarginContainer/VBoxContainer/SelectButton
@onready var locked_label: Label = $MarginContainer/VBoxContainer/LockedLabel


func _ready() -> void:
	# First, load any unlock progress from the save file.
	# This modifies the CHARACTERS_DATA dictionary before we display anything.
	_load_character_unlocks()

	# Now, proceed with the original setup
	character_keys = CHARACTERS_DATA.keys()

	# Connect buttons' "pressed" signals to their handler functions
	next_button.pressed.connect(_on_next_button_pressed)
	previous_button.pressed.connect(_on_previous_button_pressed)
	select_button.pressed.connect(_on_select_button_pressed)

	# Initialize the display to show the first character
	update_character_display()


# This new function reads the save file and updates the lock status.
func _load_character_unlocks():
	var save_path = "user://save_game.cfg"
	var config = ConfigFile.new()
	
	# Attempt to load the save file. If it doesn't exist, exit the function.
	var err = config.load(save_path)
	if err != OK:
		print("No save file found. Using default character locks.")
		return
	
	# Check the "[Characters]" section of the save file for each character.
	# get_value() safely returns 'false' if the key doesn't exist.
	if config.get_value("Characters", "Destroyer_unlocked", false):
		CHARACTERS_DATA["Destroyer"]["locked"] = false
		
	if config.get_value("Characters", "Racer_unlocked", false):
		CHARACTERS_DATA["Racer"]["locked"] = false
		
	if config.get_value("Characters", "Flowmaster_unlocked", false):
		CHARACTERS_DATA["Flowmaster"]["locked"] = false


# Updates all UI elements to reflect the currently selected character.
func update_character_display() -> void:
	# Clear any old character model from the viewport
	for child in character_viewport.get_children():
		child.queue_free()

	# Get the data for the current character
	var current_key = character_keys[current_character_index]
	var current_data = CHARACTERS_DATA[current_key]

	# Update text labels
	name_label.text = current_data["name"]
	description_label.text = current_data["description"]

	# Load and instantiate the character scene into the viewport
	var character_scene = load(current_data["scene_path"])
	if character_scene:
		var character_instance = character_scene.instantiate()
		
		# Set character to UI mode if the function exists
		if character_instance.has_method("enter_ui_mode"):
			character_instance.enter_ui_mode()
		else:
			print("Warning: Character ", character_instance.name, " does not have enter_ui_mode() function.")
			
		character_viewport.add_child(character_instance)
		character_instance.position = character_viewport.size / 2
	
	# Check the lock status and update the Select button and Locked label
	var is_locked = current_data.get("locked", false)
	if is_locked:
		select_button.disabled = true
		select_button.text = "Locked"
		select_button.modulate = Color(0.5, 0.5, 0.5) # Gray out
		locked_label.visible = true
	else:
		select_button.disabled = false
		select_button.text = "Select"
		select_button.modulate = Color(1, 1, 1) # Normal color
		locked_label.visible = false


# Called when the "Next" button is pressed.
func _on_next_button_pressed() -> void:
	current_character_index += 1
	# Loop back to the start if we go past the end
	if current_character_index >= character_keys.size():
		current_character_index = 0
	update_character_display()


# Called when the "Previous" button is pressed.
func _on_previous_button_pressed() -> void:
	current_character_index -= 1
	# Loop to the end if we go before the start
	if current_character_index < 0:
		current_character_index = character_keys.size() - 1
	update_character_display()


# Called when the "Select" button is pressed.
func _on_select_button_pressed() -> void:
	# Get the selected character's data
	var selected_key = character_keys[current_character_index]
	var selected_character_data = CHARACTERS_DATA[selected_key]

	# 存储到 GlobalData 而不是 GlobalState
	GlobalData.selected_character = selected_character_data["name"]
	GlobalData.selected_character_scene_path = selected_character_data["scene_path"]

	# Go to the next screen (e.g., level select or the first level)
	print("Selected character: ", selected_character_data["name"])
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/level_select_screen.tscn")


# Called when the "Back" button is pressed.
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/start_page.tscn")
