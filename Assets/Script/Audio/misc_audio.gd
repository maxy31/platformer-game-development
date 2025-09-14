extends Node

@onready var audio_button_click: AudioStreamPlayer2D = $Button_Click
@onready var audio_falling_arrow: AudioStreamPlayer2D = $Falling_Arrow

func play_button_click():
	if audio_button_click.stream:
		audio_button_click.play()

func play_falling_arrow():
	if audio_falling_arrow.stream:
		audio_falling_arrow.play()
