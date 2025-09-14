extends Node

@onready var bgm_player: AudioStreamPlayer = $BgmPlayer

# Keep track of the currently playing music
var current_track_path: String = ""

func _ready() -> void:
	# For the initial start, call our new function
	change_music("res://Assets/Audio/BGM/Main_Menu.wav")
	bgm_player.finished.connect(bgm_player.play)

func change_music(new_music_path: String) -> void:
	if new_music_path == current_track_path:
		return

	# If it's a new track, load and play it.
	bgm_player.stream = load(new_music_path)
	bgm_player.play()
	
	# Update the current track path
	current_track_path = new_music_path
