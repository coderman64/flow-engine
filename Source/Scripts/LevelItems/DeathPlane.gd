### DeathPlane.gd
# Controls the "plane of death".

extends Area2D

func _ready () -> void:
	helper_functions._whocares = self.connect ("area_entered", self, "_on_DeathPlane_area_entered")
	return

## _on_DeathPlane_area_entered
# Something has entered the death plane, deal with it.
func _on_DeathPlane_area_entered (area) -> void:
	if (area is game_space.player_class):
		# If the player has entered the death plane, they lose a life.
		game_space.lives -= 1
	else:						# Anything else gets destroyed.
		print_debug (area.name, " has entered the death plane.")
		area.queue_free ()
	return
