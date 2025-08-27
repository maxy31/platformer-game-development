extends Node2D

@export var damage_to_player : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RacerController or body.is_in_group("Player"):
		print("Contacted with spike trap")
		body.take_damage(damage_to_player, global_position)
