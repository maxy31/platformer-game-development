extends Node

# This variable will hold the current volume setting (from 0.0 to 1.0)
# and will be accessible from anywhere in your game.
var master_volume_linear: float = 1.0

# This function will update the actual game audio whenever the variable is changed.
func update_audio_server():
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(master_volume_linear))
