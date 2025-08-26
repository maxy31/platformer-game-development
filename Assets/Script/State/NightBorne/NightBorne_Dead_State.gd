extends State_1_0

#@export var health_drop_chance : float = 0.25
#@export var health_potion_scene : PackedScene
#
#@export var coin_drop_chance : float = 0.60
#@export var coin_item_scene : PackedScene

var is_dead = false

func enter():
	if is_dead:
		return
	super.enter()
	animation_player.play("Dead")
	await animation_player.animation_finished
	
	is_dead = true
	#if randi() % 100 < int(health_drop_chance * 100):
		#var health_potion_instance = health_potion_scene.instantiate()
		#health_potion_instance.global_position = get_parent().get_parent().global_position + Vector2(-15, 0)
		#get_parent().get_parent().get_parent().call_deferred("add_child", health_potion_instance)
	#if randi() % 100 < int(coin_drop_chance * 100):
		#var coin_item_instance = coin_item_scene.instantiate()
		#coin_item_instance.global_position = get_parent().get_parent().global_position + Vector2(15, 0)
		#get_parent().get_parent().get_parent().call_deferred("add_child", coin_item_instance)
