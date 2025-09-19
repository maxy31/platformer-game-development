extends CanvasLayer

@onready var panel = $Panel
@onready var restart_button = $Panel/Restart
@onready var quit_button = $Panel/Quit

func _ready():
	# Debug check
	print("✅ GameOverUI ready")
	print("Panel children:", panel.get_children())

	# Connect signals (editor connection also works, this is fallback)
	if not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)
	if not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

	visible = false  # start hidden

func show_game_over():
	print("⚡ Game Over UI shown")
	visible = true
	get_tree().paused = true  # pause game
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart_pressed():
	print("🔄 Restart button pressed")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	print("❌ Quit button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/start_page.tscn")
