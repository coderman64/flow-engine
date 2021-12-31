### chaos_festival.gd
# Specific script for a test level.

extends "res://Scripts/Levels/level_generic.gd"

func _ready () -> void:
	if (not has_node ("/root/Level/Player")):	# No player? Add them to the scene.
		helper_functions.add_path_to_node ("res://Scenes/Player/player_sonic.tscn", "/root/Level")
		yield (get_tree (), "idle_frame")		# And make sure they're added before continuing...
		helper_functions.add_path_to_node ("res://Scenes/Levels/chaos_festival_particles.tscn", "/root/Level/Player")
	$zone_intro.play_me ()
	return
