### Ring.gd
# Controls a typical (non-flying) ring

extends Area2D

var ring_collected := false	# Has the ring been collected?

# holds a reference to the AnimatedSprite node for the ring
onready var ring_sprite := get_node ("AnimatedSprite")

func _ready () -> void:
	helper_functions._whocares = self.connect ("area_entered", self, "_on_Ring_area_entered")
	return

# if the sprite has been collected, remove once the sparkle animation finishes
func _process (_delta) -> void:
	if (ring_collected and ring_sprite.animation == "Sparkle" and ring_sprite.frame >= 6):
		queue_free ()
	return

## _on_Ring_area_entered
# Deals with things colliding with rings and what to do.
func _on_Ring_area_entered (area) -> void:
	if (not ring_collected and area is game_space.player_class):
		# The player has collided with the ring, collect it.
		ring_collected = true
		ring_sprite.animation = "Sparkle"
		sound_player.play_sound ("ring_get")
		game_space.rings_collected += 1
		game_space.score += 100
		game_space.change_boost_value (2)
	return
