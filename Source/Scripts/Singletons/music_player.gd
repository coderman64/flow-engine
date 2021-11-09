### music_player - a singleton to be used to play music (normally looped, but whatever is necessary).
# For more advanced stuff (music that relies on signals and so on), do it in the scene directly.

extends AudioStreamPlayer

# If something needs to access the audio bus used by the player, it can be found here.
onready var bus_index := AudioServer.get_bus_index ("Music")

# Set up the volume with the initial DB value for the audio bus.
# Remember to use linear2db/db2linear to convert this as necessary!
onready var bus_volume := AudioServer.get_bus_volume_db (bus_index) setget set_bus_volume

## play_music
# music_player.play_music (path_to_music, play_from)
# Plays a specified music file (path_to_music).
# Will play from a specific point in the music (in seconds) if told to (play_from).
# Returns true if it plays something, otherwise false.
func play_music (path_to_music = "", play_from = 0.0) -> void:
	var play_me = null		# This will be used to set the stream data.
	if (not ResourceLoader.exists (path_to_music)):	# The music file doesn't actually exist.
		printerr ("ERROR: music_player has no music to play! ", path_to_music, " does not exist.")
		return
	play_me = load (path_to_music) as AudioStream
	stream = play_me		# Everything's OK, so set the stream as needed?
	if (stream == null):	# Except it's not actually a music file, so error out.
		printerr ("ERROR: music_player has an empty stream! ", path_to_music, " is not a valid music file!")
		return
	print_debug ("Playing ", stream, " from ", path_to_music, ", offset ", play_from, ".")
	AudioServer.set_bus_mute (bus_index, false)		# Unmute the Music bus...
	play (play_from)								# ...and play the music.
	return

## stop_music
# music_player.stop_music ()
# Just a bit of syntactic sugar. Stops the currently playing music.
func stop_music () -> void:
	stop ()
	return

## set_bus_volume
# Adjusts the bus volume.
func set_bus_volume (value:float) -> void:
	value = clamp (value, 0.0, 1.0)	# Ensure sanity prevails.
	AudioServer.set_bus_volume_db (bus_index, linear2db (value))
	bus_volume = AudioServer.get_bus_volume_db (bus_index)
	return
