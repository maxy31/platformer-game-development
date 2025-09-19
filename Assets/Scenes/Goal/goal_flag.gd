# goal_flag.gd (Version 3 - Calling the dialogue library)
extends Node2D

signal level_completed

@export var dialogue_ui: CanvasLayer
@export var victory_ui: Control

var triggered: bool = false
var player_ref: Node2D = null

func _ready() -> void:
		# Check if dialogue_ui has been set correctly in the editor
	if not is_instance_valid(dialogue_ui):
		# push_error will display a clickable error message in the editor, which is very convenient
		push_error("Error: In scene '" + get_tree().current_scene.scene_file_path + "', the GoalFlag node has not been assigned a DialogueUI node! Please set it in the inspector.")
		# Disable itself to avoid further errors
		set_process(false)
		set_physics_process(false)
		return # Exit the function early

	#  Also check victory_ui
	if not is_instance_valid(victory_ui):
		push_error("Error: In scene '" + get_tree().current_scene.scene_file_path + "', the GoalFlag node has not been assigned a VictoryUI node!")
		set_process(false)
		set_physics_process(false)
		return
		
	print("This Goal Flag is running inside scene: ", get_tree().current_scene.scene_file_path)
	dialogue_ui.dialogue_finished.connect(on_dialogue_finished)
	print("This Goal Flag is running inside scene: ", get_tree().current_scene.scene_file_path)

	if not dialogue_ui:
		push_error("错误：GoalFlag 脚本中没有分配 DialogueUI 节点！")
		return
	if not victory_ui:
		push_error("错误：GoalFlag 脚本中没有分配 VictoryUI 节点！")
		return
	dialogue_ui.dialogue_finished.connect(on_dialogue_finished)
	
func _process(delta: float) -> void:
	# We check if the dialogue_ui is still a valid node.
	# If not, we print an error.
	if not is_instance_valid(dialogue_ui):
		print("!!! CRITICAL WARNING: The DialogueUI node has been deleted or removed !!!")
		# We can disable this function after it triggers once to avoid spam.
		set_process(false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not triggered:
		print("DEBUG 1: Player has entered the GoalFlag area.")
		player_ref = body
		triggered = true
		print("DEBUG 2: The assigned dialogue_ui node is: ", dialogue_ui.name)
		# [CORE CHANGE]
		# No longer need to define dialogue content here
		# Directly tell DialogueUI to play the "victory_dialogue" conversation
		
		dialogue_ui.start_dialogue_from_library("victory_dialogue")
		# STEP 3: The MOST IMPORTANT CHECK.
		# Does the 'dialogue_ui' node's script actually HAVE the function we want to call?
		if dialogue_ui.has_method("start_dialogue_from_library"):
			print("DEBUG 3: SUCCESS! The node '", dialogue_ui.name, "' has the function 'start_dialogue_from_library'.")
			
			# Now we can safely call it.
			dialogue_ui.start_dialogue_from_library("victory_dialogue")
		
		else:
			# If the function does not exist, this error message will tell us EXACTLY what the problem is.
			push_error("DEBUG 3: FAILED! The node '", dialogue_ui.name, "' is MISSING the function 'start_dialogue_from_library'. Check the script attached to that node.")
			
		# --- END DEBUGGING ---
		

func on_dialogue_finished() -> void:
	print("💬 Dialogue finished, triggering victory logic!")

	if is_instance_valid(player_ref):
		print("DEBUG (Goal): The 'player_ref' IS valid.")
		if player_ref.has_method("play_level_complete_sound"):
			print("DEBUG (Goal): SUCCESS! Calling the player's sound function now.") #Until this line is displayed
			player_ref.play_level_complete_sound()
		else:
			print("DEBUG (Goal): FAILED! The player node is missing the function.")
	else:
		# If this was reached, means player_ref was never set in the first place.
		print("DEBUG (Goal): FAILED! The 'player_ref' is EMPTY/NULL.")
	# ---------------------------------------------
	emit_signal("level_completed")
	if victory_ui:
		# Pause the entire game before showing the victory UI to achieve a "freeze frame" effect
		get_tree().paused = true
		victory_ui.show_victory()
