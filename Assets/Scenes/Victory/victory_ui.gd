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
	get_tree().paused = false   # 🔓 Unpause before changing scene
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/start_page.tscn")

func _on_next_level_pressed():
	print("⏭️ Next Level pressed")
	get_tree().paused = false

	var current_scene_path = get_tree().current_scene.scene_file_path
	print("📂 Current scene path:", current_scene_path)

	var regex = RegEx.new()
	var match_result = null
	if regex.compile("level(\\d+)\\.tscn") == OK:
		match_result = regex.search(current_scene_path)

	if match_result:
		var current_level_number = match_result.get_string(1).to_int()
		var next_level_number = current_level_number + 1
		var next_level_path = "res://Assets/Scenes/Areas/level%d.tscn" % next_level_number

		# 🔐 Save unlocked level to file
		var save_path = "user://save_game.cfg"
		var config = ConfigFile.new()

		# Load existing config
		var err = config.load(save_path)
		if err != OK:
			print("⚠️ Couldn't load save, starting new one")

		# Save highest unlocked level
		var prev_unlocked = config.get_value("Progress", "unlocked_level", 1)
		if next_level_number > prev_unlocked:
			config.set_value("Progress", "unlocked_level", next_level_number)
			config.save(save_path)
			print("💾 Progress saved: unlocked level", next_level_number)

		# Load the next level if it exists
		if ResourceLoader.exists(next_level_path):
			print("➡️ Loading next level:", next_level_path)
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("🏁 No more levels. Scene not found:", next_level_path)
	else:
		print("❌ Could not detect level number in current scene path.")
