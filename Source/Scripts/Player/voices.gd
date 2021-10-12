### voices.gd
# Plays a random voice file.

extends AudioStreamPlayer2D

export(Array, AudioStream) var hurt

export(Array, AudioStream) var effort

func play_hurt () -> void:
	stream = hurt [floor (hurt.size () * random_helpers.RNG.randf ())]
	play (0)
	return

func play_effort () -> void:
	stream = effort [floor (effort.size () * random_helpers.RNG.randf ())]
	play (0)
	return
