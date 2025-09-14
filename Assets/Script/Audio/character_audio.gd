extends Node

@onready var audio_character_walk: AudioStreamPlayer2D = $Character_Walk
@onready var audio_cheese_pickup: AudioStreamPlayer2D = $Cheese_Pickup
@onready var audio_game_over: AudioStreamPlayer2D = $Game_Over
@onready var audio_health_regen: AudioStreamPlayer2D = $Health_Regen
@onready var audio_jump: AudioStreamPlayer2D = $Jump
@onready var audio_level_completed: AudioStreamPlayer2D = $Level_Completed
@onready var audio_magic_cast: AudioStreamPlayer2D = $Magic_Cast
@onready var audio_punch_not_hit: AudioStreamPlayer2D = $Punch_Not_Hit
@onready var audio_punch_on_hit: AudioStreamPlayer2D = $Punch_On_Hit
@onready var audio_walk: AudioStreamPlayer2D = $Racer_Walk
@onready var audio_take_damage: AudioStreamPlayer2D = $Take_Damage
@onready var audio_weapon_swoosh: AudioStreamPlayer2D = $Weapon_Not_Hit
@onready var audio_weapon_hit: AudioStreamPlayer2D = $Weapon_On_Hit
	
func play_cheese_pickup_sound():
	if audio_cheese_pickup.stream:
		audio_cheese_pickup.play()

func play_game_over_sound():
	# Note: Make sure this node's Process Mode is set to "Always" in the Inspector
	# so it can play even when the game is paused.
	if audio_game_over.stream:
		audio_game_over.play()

func play_health_regen_sound():
	if audio_health_regen.stream:
		audio_health_regen.play()

func play_jump_sound():
	if audio_jump.stream:
		audio_jump.play()

func play_level_complete_sound():
	# Note: Make sure this node's Process Mode is set to "Always" in the Inspector
	# so it can play even when the game is paused.
	if audio_level_completed.stream:
		audio_level_completed.play()

func play_magic_cast_sound():
	if audio_magic_cast.stream:
		audio_magic_cast.play()

func play_punch_swoosh_sound():
	if audio_punch_not_hit.stream:
		audio_punch_not_hit.play()

func play_punch_hit_sound():
	if audio_punch_on_hit.stream:
		# Randomizing pitch makes hits sound more natural and less repetitive.
		audio_punch_on_hit.pitch_scale = randf_range(0.9, 1.1)
		audio_punch_on_hit.play()

func play_take_damage_sound():
	if audio_take_damage.stream:
		audio_take_damage.pitch_scale = randf_range(0.85, 1.15)
		audio_take_damage.play()

func play_weapon_swoosh_sound():
	if audio_weapon_swoosh.stream:
		audio_weapon_swoosh.play()

func play_weapon_hit_sound():
	if audio_weapon_hit.stream:
		audio_weapon_hit.pitch_scale = randf_range(0.9, 1.1)
		audio_weapon_hit.play()


# --- LOOPING SOUNDS (Require Start/Stop logic) ---

# Note: You have two "walk" sounds. Here are functions for both.
# If you only need one, you can delete the extra pair.

# For 'Character_walk'
func start_character_walk():
	# Note: Ensure the audio file is set to "Loop" in the Import tab.
	if audio_character_walk.stream and not audio_character_walk.is_playing():
		audio_character_walk.play()

func stop_character_walk():
	if audio_character_walk.is_playing():
		audio_character_walk.stop()

# For 'Racer_walk'
func start_racer_walk():
	# Note: Ensure the audio file is set to "Loop" in the Import tab.
	if audio_walk.stream and not audio_walk.is_playing():
		audio_walk.play()

func stop_racer_walk():
	if audio_walk.is_playing():
		audio_walk.stop()
