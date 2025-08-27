extends Node2D

signal level_completed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("level_completed")
		
		# Access the Control node inside the VictoryUI CanvasLayer
		var ui = get_tree().current_scene.get_node("VictoryUI/VictoryUI")
		print("🔍 ui node found?", ui)
		print("📂 Scene tree of current scene:")
		get_tree().current_scene.print_tree_pretty()
		if ui:
			ui.show_victory()
