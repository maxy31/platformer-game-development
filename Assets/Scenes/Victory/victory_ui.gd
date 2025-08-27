extends Control

@onready var restart_button = $Panel/Restart
@onready var quit_button = $Panel/Quit
@onready var next_level_button = $Panel/NextLevel  # New button

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false  # Start hidden
	
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	next_level_button.pressed.connect(_on_next_level_pressed)

func show_victory():
	print("🎉 Victory screen shown")
	visible = true
	print("👁️ VictoryUI visible now?", visible)
	print("🖼️ Global rect:", get_global_rect())
	get_tree().paused = true

func _on_restart_pressed():
	print("🔄 Restart pressed")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	print("❌ Quit pressed")
	get_tree().quit()

func _on_next_level_pressed():
	print("⏭️ Next Level pressed")
	get_tree().paused = false

	var current_scene_path = get_tree().current_scene.scene_file_path
	print("📂 Current scene path:", current_scene_path)

	# Match filename like 'level1.tscn'
	var regex = RegEx.new()
	var match_result = null
	if regex.compile("level(\\d+)\\.tscn") == OK:
		match_result = regex.search(current_scene_path)

	if match_result:
		var current_level_number = match_result.get_string(1).to_int()
		var next_level_number = current_level_number + 1
		var next_level_path = "res://Assets/Scenes/Areas/level%d.tscn" % next_level_number

		if ResourceLoader.exists(next_level_path):
			print("➡️ Loading next level:", next_level_path)
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("🏁 No more levels. Scene not found:", next_level_path)
	else:
		print("❌ Could not detect level number in current scene path.")
