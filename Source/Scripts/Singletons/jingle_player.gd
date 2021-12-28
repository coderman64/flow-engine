### jingle_player - a singleton to play music as a jingle.
# What this does is as follows:
# 1 - Mutes the Music bus. This way any music will carry on playing, just silently.
# 2 - plays the specified jingle.
# 3 - at the end of the jingle, unmutes Music (if wanted; the default) so anything playing becomes
#     audible again.

# It can either emit a "jingle_finished" signal (for having played the jingle in its entirety), or
# "jingle_aborted" (for a jingle having been stopped by something else).

extends AudioStreamPlayer

signal jingle_finished	# Jingle played from start to finish.
signal jingle_aborted	# Jingle has been told to stop playing before it finished.

# If something needs to access the audio bus used by the player, it can be found here.
onready var bus_index := AudioServer.get_bus_index ("Jingles")

# Set up the volume with the initial DB value for the audio bus.
# Remember to use linear2db/db2linear to convert this as necessary!
onready var bus_volume := AudioServer.get_bus_volume_db (bus_index) setget set_bus_volume

# True (the default) will unmute the Music bus after playing the jingle; false will not.
var unmute_music:bool = true

func _ready () -> void:
	helper_functions._whocares = self.connect ("finished", self, "stop_jingle")
	return

## play_jingle
# jingle_player.play_jingle (path_to_jingle, music_unmute)
# Plays a specified music file as a jingle (path_to_jingle), muting the Music bus beforehand.
# After the jingle is finished, music_unmute can be set false to leave the music bus muted.
# Returns true if it plays something, otherwise false.
func play_jingle (path_to_jingle = "", music_unmute = true) -> void:
	var play_me = null			# This will hold the stream for the jingle.
	unmute_music = music_unmute	# Make sure music will be muted/unmuted after this jingle is done.
	if (not ResourceLoader.exists (path_to_jingle)):	# The file doesn't exist, so say so.
		printerr ("ERROR: jingle_player has no jingle to play! ", path_to_jingle, " does not exist!")
		return
	play_me = load (path_to_jingle) as AudioStream
	stream = play_me		# Set the stream.
	if (stream == null):	# If the stream is null, this means the sound file is invalid, so report an error.
		printerr ("ERROR: jingle_player has an empty stream! ", path_to_jingle, " is not a valid sound file.")
		return
	print_debug ("Playing ", stream, " from ", path_to_jingle, ".")
	AudioServer.set_bus_mute (music_player.bus_index, true)		# Mute the Music bus...
	play ()														# ...play the jingle...
	return														# ...and return.

## stop_jingle
# jingle_player.stop_jingle (abort_jingle)
# Stops the currently playing jingle and unmutes Music if told to.
# If abort_jingle is true, then it'll emit "jingle_aborted", otherwise "jingle_finished".
# You may need to unmute Music manually yourself in code if you leave it muted.
func stop_jingle (abort_jingle = false) -> void:
	stop ()
	if (unmute_music):	# The default - unmute the music bus if this is true.
		# music_player unmutes Music if told to play something.
		AudioServer.set_bus_mute (music_player.bus_index, false)
	unmute_music = true	# As this is a singleton, reset unmute_music after the check!
	if (abort_jingle):	# The jingle has been terminated early, so emit the "jingle_aborted" signal.
		emit_signal ("jingle_aborted")
	else:	# Jingle has played through.
		emit_signal ("jingle_finished")
	return

## set_bus_volume
# Adjusts the bus volume.
func set_bus_volume (value:float) -> void:
	value = clamp (value, 0.0, 1.0)	# Ensure sanity prevails.
	AudioServer.set_bus_volume_db (bus_index, linear2db (value))
	bus_volume = AudioServer.get_bus_volume_db (bus_index)
	return
