extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("PlayerController"):
		return
	
	var racer := body as RacerController
	if racer != null:
		racer.take_damage(1, global_position)
