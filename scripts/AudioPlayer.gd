# plays audio with intro and loop sections

extends AudioStreamPlayer

# the time, in seconds, to loop back to once the end is reached.
export(float) var loopbackTime = 13.25

# automatically play the track on startup
export(bool) var _autoPlay = true

# records whether or not the track is in the loopable 
# section yet
var loopbackFlag = false

# automatically play the track if "autoplay" is enabled
func _ready():
	if _autoPlay:
		play(0)

func _process(_delta):
	# set the loopback flag if we are in the loopable section
	if get_playback_position() > loopbackTime:
		loopbackFlag = true

	# if the track loops back to the beginning, automatically 
	# skip to the loopable section instead
	if get_playback_position() < loopbackTime and loopbackFlag:
		seek(loopbackTime)

