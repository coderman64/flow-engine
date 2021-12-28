extends Node2D

func _ready() -> void:
	if (not get_node ("..").level_logo == ""):
		$"zone_logo".texture = load (get_node ("..").level_logo)
	return

func play_me () -> void:
	game_space.player_node.is_unmoveable = true
	game_space.get_node ("level_timer").stop ()
	$"/root/Level/game_hud".offset = Vector2 (-1000000, -1000000)
	$"AnimationPlayer".play ("intro_in")
	yield (get_node ("AnimationPlayer"), "animation_finished")
	done_me ()
	return

func done_me () -> void:
	game_space.player_node.is_unmoveable = false
	$"/root/Level/game_hud".offset = Vector2.ZERO
	game_space.get_node ("level_timer").start ()
	queue_free ()
	return
