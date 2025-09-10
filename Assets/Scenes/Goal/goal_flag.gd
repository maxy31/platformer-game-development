# goal_flag.gd (版本 3 - 调用对话库)
extends Node2D

signal level_completed

@export var dialogue_ui: CanvasLayer
@export var victory_ui: Control

var triggered: bool = false

func _ready() -> void:
	if not dialogue_ui:
		push_error("错误：GoalFlag 脚本中没有分配 DialogueUI 节点！")
		return
	if not victory_ui:
		push_error("错误：GoalFlag 脚本中没有分配 VictoryUI 节点！")
		return
	dialogue_ui.dialogue_finished.connect(on_dialogue_finished)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not triggered:
		triggered = true
		
		# 【核心改动】
		# 不再需要自己定义对话内容了
		# 直接告诉 DialogueUI 播放 "victory_dialogue" 这段对话
		dialogue_ui.start_dialogue_from_library("victory_dialogue")

func on_dialogue_finished() -> void:
	print("💬 对话结束，触发胜利逻辑！")
	emit_signal("level_completed")
	if victory_ui:
		# --- 新增代码在这里 ---
		# 在显示胜利UI之前，暂停整个游戏，实现“静止画面”效果
		get_tree().paused = true
		# --------------------
		victory_ui.show_victory()
