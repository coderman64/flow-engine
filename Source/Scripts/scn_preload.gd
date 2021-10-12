### The preloader script.
# This scene should just be used for (pre)loading stuff and then switching to the first "proper" scene of
# the program.
# This scene is (by default) a Node2D in case you want some kind of loading screen here.

extends Node2D

func _ready () -> void:
	config_helper.load_config ()
	# Add sounds to the sound player.
	sound_player.add_sound_to_library ("res://Assets/Audio/Sound/Enemies/boom.ogg", "enemy_boom")
	sound_player.add_sound_to_library ("res://Assets/Audio/Sound/Player/lose_rings.ogg", "lose_rings")
	sound_player.add_sound_to_library ("res://Assets/Audio/Sound/LevelItems/Checkpoint.ogg", "pass_checkpoint")
	sound_player.add_sound_to_library ("res://Assets/Audio/Sound/Player/Death.ogg", "player_death")
	sound_player.add_sound_to_library ("res://Assets/Audio/Sound/Player/jump.ogg", "player_jump")
	sound_player.add_sound_to_library ("res://Assets/Audio/Sound/LevelItems/ring.ogg", "ring_get")
	helper_functions._whocares = helper_functions.change_scene ("res://Scenes/UI/main_menu.tscn")
	return
