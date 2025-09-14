# goal_flag.gd (版本 3 - 调用对话库)
extends Node2D

signal level_completed

@export var dialogue_ui: CanvasLayer
@export var victory_ui: Control

var triggered: bool = false
var player_ref: Node2D = null

func _ready() -> void:
		# 检查在编辑器里是否已经正确设置了 dialogue_ui
	if not is_instance_valid(dialogue_ui):
		# push_error 会在编辑器里显示一个可点击的错误信息，非常方便
		push_error("错误：在场景 '" + get_tree().current_scene.scene_file_path + "' 中, GoalFlag 节点没有分配 DialogueUI 节点！请在检查器中设置它。")
		# 禁用自己，避免后续出错
		set_process(false)
		set_physics_process(false)
		return # 提前退出函数

	# 同样的，也检查 victory_ui
	if not is_instance_valid(victory_ui):
		push_error("错误：在场景 '" + get_tree().current_scene.scene_file_path + "' 中, GoalFlag 节点没有分配 VictoryUI 节点！")
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
		# 【核心改动】
		# 不再需要自己定义对话内容了
		# 直接告诉 DialogueUI 播放 "victory_dialogue" 这段对话
		
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
	print("💬 对话结束，触发胜利逻辑！")
	# --- THIS IS THE PERFECT PLACE FOR THE SOUND ---
	# First, check if we have a valid reference to the player
	if is_instance_valid(player_ref):
		# Now, call the function you created on the player's script
		print("DEBUG (Goal): The 'player_ref' IS valid.")
		if player_ref.has_method("play_level_complete_sound"):
			print("DEBUG (Goal): SUCCESS! Calling the player's sound function now.") #Until this line is displayed
			player_ref.play_level_complete_sound()
		else:
			print("DEBUG (Goal): FAILED! The player node is missing the function.")
	else:
		# If you see this, it means player_ref was never set in the first place.
		print("DEBUG (Goal): FAILED! The 'player_ref' is EMPTY/NULL.")
	# ---------------------------------------------
	emit_signal("level_completed")
	if victory_ui:
		# --- 新增代码在这里 ---
		# 在显示胜利UI之前，暂停整个游戏，实现“静止画面”效果
		get_tree().paused = true
		# --------------------
		victory_ui.show_victory()
		
# Add this entire function to goal_flag.gd
