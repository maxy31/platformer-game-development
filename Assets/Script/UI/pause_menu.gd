extends Control
@onready var h_slider: HSlider = $VolumeSlider # <--- Add this to get the slider node
func _ready():
	h_slider.visible = false
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	h_slider.visible = false
	hide()  # hide the pause menu UI

	# wait one frame before playing animation
	await get_tree().process_frame

	# play reverse blur
	if $AnimationPlayer.has_animation("blur"):
		$AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	h_slider.visible = true
	show()  # show the pause menu UI

	# play blur animation
	if $AnimationPlayer.has_animation("blur"):
		$AnimationPlayer.play("blur")
	
func testMenu():
	if Input.is_action_just_pressed("menu") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("menu") and get_tree().paused == true:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://Assets/Scenes/Global/start_page.tscn")
	
func _process(delta):
	testMenu()
