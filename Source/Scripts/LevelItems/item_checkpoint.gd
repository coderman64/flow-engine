### item_checkpoint.gd
# Operates checkpoints that the player is returned to if they die.

extends Area2D

export(Vector2) var last_time = Vector2.ZERO		# Time when the player passes the checkpoint.
var passed_checkpoint:bool = false					# Passed the checkpoint yet?

func _ready() -> void:
	helper_functions._whocares = self.connect ("area_entered", self, "_on_Checkpoint_area_entered")
	return

## _on_Checkpoint_area_entered
# If something passes the checkpoint by, deal with it.
func _on_Checkpoint_area_entered (area) -> void:
	if (not passed_checkpoint and area is game_space.player_class):	# It's the player, tag them.
		passed_checkpoint = true
		game_space.last_checkpoint = self	# Mark the last checkpoint crossed as this one!
		last_time = game_space.timer		# Mark the current time.
		print_debug (self, " (", self.name, ") was passed.")
		# Change the animation playing, play the relevant sound.
		$"AnimationPlayer".play_backwards ("spin_green")
		sound_player.play_sound ("pass_checkpoint")
	return
