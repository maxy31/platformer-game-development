extends Node

@onready var bat_wing_flap_player: AudioStreamPlayer2D = $Bat_Wing_Flap
@onready var crab_noise_player: AudioStreamPlayer2D = $Crab_Enemy_Noise
@onready var crab_walking_player: AudioStreamPlayer2D = $Crab_Enemy_Walking
@onready var monster_spotted_player: AudioStreamPlayer2D = $Monster_Spotted
@onready var monster_walk_growl_player: AudioStreamPlayer2D = $Monster_Walk_Growl
@onready var nighborne_swing_player: AudioStreamPlayer2D = $NighBorne_Greatsword_Swing
@onready var skeleton_swing_player: AudioStreamPlayer2D = $Skeleton_Axe_Swing

# --- One-Shot Sounds (Play once) ---
	
func play_monster_spotted():
	if monster_spotted_player.stream:
		monster_spotted_player.play()

func play_nighborne_swing():
	if nighborne_swing_player.stream:
		nighborne_swing_player.pitch_scale = randf_range(0.9, 1.1)
		nighborne_swing_player.play()

func play_skeleton_swing():
	if skeleton_swing_player.stream:
		skeleton_swing_player.pitch_scale = randf_range(0.9, 1.1)
		skeleton_swing_player.play()


# --- Looping Sounds (Need to be started and stopped) ---
# Note: For these, make sure the audio file is set to "Loop" in the Import tab.

func start_bat_wings():
	if bat_wing_flap_player.stream and not bat_wing_flap_player.is_playing():
		bat_wing_flap_player.play()

func stop_bat_wings():
	if bat_wing_flap_player.is_playing():
		bat_wing_flap_player.stop()

func start_crab_idle_noise():
	if crab_noise_player.stream and not crab_noise_player.is_playing():
		crab_noise_player.play()

func stop_crab_idle_noise():
	if crab_noise_player.is_playing():
		crab_noise_player.stop()

func start_crab_walking():
	if crab_walking_player.stream and not crab_walking_player.is_playing():
		crab_walking_player.play()

func stop_crab_walking():
	if crab_walking_player.is_playing():
		crab_walking_player.stop()

func start_monster_walk_growl():
	if monster_walk_growl_player.stream and not monster_walk_growl_player.is_playing():
		monster_walk_growl_player.play()

func stop_monster_walk_growl():
	if monster_walk_growl_player.is_playing():
		monster_walk_growl_player.stop()


# --- UTILITY FUNCTION (VERY IMPORTANT!) ---
# This stops all looping sounds to prevent overlap when changing states.
func stop_all_looping_sounds():
	stop_bat_wings()
	stop_crab_idle_noise()
	stop_crab_walking()
	stop_monster_walk_growl()
