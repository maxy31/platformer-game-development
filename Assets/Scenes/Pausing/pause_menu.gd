extends Control

func _ready():
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	hide()  # hide the pause menu UI

	# wait one frame before playing animation
	await get_tree().process_frame

	# play reverse blur
	if $AnimationPlayer.has_animation("blur"):
		$AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true
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
	get_tree().quit()
	
func _process(delta):
	testMenu()
