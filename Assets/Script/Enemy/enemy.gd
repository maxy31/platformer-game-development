extends CharacterBody2D
class_name Enemy

@export var max_health := 3
@export var contact_damage := 1       # Damage dealt to players on contact
@export var attack_interval := 1.0    # Damage frequency to players

var current_health := max_health

#List of players in contact
var players_in_contact: Array = []
# Store a separate cooldown for each player
var attack_timers := {}

func _ready():
	if has_node("HitBox"):
		$HitBox.body_entered.connect(_on_hitbox_body_entered)
		$HitBox.body_exited.connect(_on_hitbox_body_exited)

func _physics_process(delta: float) -> void:
	# Iterate through all players in contact
	for player in players_in_contact:
		if not is_instance_valid(player):
			continue

		# Update this player's attack timer
		if not attack_timers.has(player):
			attack_timers[player] = 0.0

		attack_timers[player] -= delta

		# Ready to deal damage
		if attack_timers[player] <= 0.0:
			if player.has_method("take_damage"):
				print("⚠ Continous damage, dealing to player", contact_damage, " damage points")
				player.take_damage(contact_damage, global_position)
				attack_timers[player] = attack_interval  # Reset the timer

# Enemy takes damage
func take_damage(amount: int):
	current_health -= amount
	print("💥 Enemy took", amount, "damage. HP:", current_health)

	if current_health <= 0:
		die()

func die():
	print("☠ Enemy died")
	queue_free()

# Player contact declaration
func _on_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		if not players_in_contact.has(body):
			players_in_contact.append(body)
			attack_timers[body] = 0.0   # Deal damage immediately upon entry

func _on_hitbox_body_exited(body):
	if players_in_contact.has(body):
		players_in_contact.erase(body)
		attack_timers.erase(body)
