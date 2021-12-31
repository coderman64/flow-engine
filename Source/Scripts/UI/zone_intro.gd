### zone_intro.gd
# Runs the "zone intro" sequence.
# Needs to be run after the HUD is added to the level scene.

extends Node2D

func _ready() -> void:
	if (not get_node ("..").level_logo == ""):	# Does the level have a logo? If so, use it.
		$"zone_logo".texture = load (get_node ("..").level_logo)
	return

## play_me
# Actually plays the animation.
func play_me () -> void:
	game_space.player_node.is_unmoveable = true
	game_space.get_node ("level_timer").stop ()
	$"/root/Level/game_hud".offset = Vector2 (-1000000, -1000000)
	$"AnimationPlayer".play ("intro_in")
	yield ($"AnimationPlayer", "animation_finished")
	done_me ()
	return

## done_me
# The animation is done, restore player control, set the UI visible and go!
func done_me () -> void:
	game_space.player_node.is_unmoveable = false
	$"/root/Level/game_hud".offset = Vector2.ZERO
	game_space.get_node ("level_timer").start ()
	queue_free ()
	return
