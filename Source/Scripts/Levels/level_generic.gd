### level_generic.gd
# Sets up the generic patterns for a level.

extends Node2D

export(String, FILE, "*.ogg") var music_file	# Specify a file to be played.
export(String, FILE, "*.png") var level_logo	# What's the logo for this level?

func _ready () -> void:
	if (not music_file == ""):	# If there's a music file specified, play it.
		music_player.play_music (music_file)
	if (not has_node ("/root/Level/game_hud")):	# Make sure the HUD is added to the level space.
		helper_functions.add_path_to_node ("res://Scenes/UI/HUD/game_hud.tscn", "/root/Level")
		yield (get_tree (), "idle_frame")		# And make sure they're added before continuing...
	if (OS.is_debug_build ()):					# Running in debug mode?
		helper_functions.add_path_to_node ("res://Scenes/UI/HUD/debug_hud.tscn", "/root/Level")
		yield (get_tree (), "idle_frame")		# And make sure they're added before continuing...
	return
