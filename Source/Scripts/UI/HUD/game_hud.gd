### game_hud.gd
# Controls the in-game HUD.

extends CanvasLayer

func _ready() -> void:
	# When entering the scene tree, connect signals for the boost bar.
	helper_functions._whocares = $"hud_boost".connect ("value_changed", self, "on_boost_hud_value_changed")
	on_boost_hud_value_changed ($"hud_boost".value)				# Make sure the boost bar is set up correctly.
	game_space.rings_collected = game_space.rings_collected		# Make sure the rings animation plays.
	return

## on_boost_hud_value_changed
# This function makes sure the boost bar is changed. If the infinite boost cheat is enabled, boost is kept at 60.
func on_boost_hud_value_changed (changed_to: float) -> void:
	$"hud_boost".value = (60.0 if game_space.infinite_boost_cheat else changed_to)
	return
