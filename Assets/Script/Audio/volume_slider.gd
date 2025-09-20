extends HSlider

func _ready():
	# 1. Ask the global memory what the current volume should be.
	# 2. Set this slider's visual position to match that value.
	self.value = AudioSettings.master_volume_linear
	
	# Connect the signal from this slider to its own function.
	# It's good practice to do this in code to be sure.
	self.value_changed.connect(_on_value_changed)

# This function is called whenever the player moves THIS slider.
func _on_value_changed(new_value: float):
	# 1. Tell the global memory to remember the new volume.
	AudioSettings.master_volume_linear = new_value
	
	# 2. Tell the global memory to update the actual game sound.
	AudioSettings.update_audio_server()
