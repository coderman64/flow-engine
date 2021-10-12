### config_helper
# Helper functions for using config files in general.
# By default these functions save/load the following settings:
# * Fullscreen or not (Graphics/fullscreen)
# * Master volume (Audio/master)
# * Music/jingle volume (Audio/music)
# * Sound volume (Audio/sound)
# Add more as necessary.
# Note that volume settings are saved as linear values, not as dB, and converted to dB on load.

extends Node

# The default filename for settings.
onready var CONFIG_FILENAME := "user://settings.cfg"
onready var config_file = ConfigFile.new ()	# New instance for a config file if it exists?

## load_config / save_config
# helper_functions.load_config ()
# helper_functions.save_config ()
# Loads and saves configuration info (fullscreen, volume, etc) for any app.
func load_config () -> void:
	var config_ok = config_file.load (CONFIG_FILENAME)
	if (not config_ok == OK):	# Can't open a config file. May not be an error, note!
		printerr ("WARNING: load_config couldn't open a config file, code ", config_ok, " - may not be created yet.")
	# A config file exists (or probably will exist), read from it.
	OS.window_fullscreen = config_file.get_value ("Graphics", "fullscreen", false)
	helper_functions.master_bus_volume = config_file.get_value ("Audio", "master", 1.0)
	music_player.bus_volume = config_file.get_value ("Audio", "music", 1.0)
	jingle_player.bus_volume = config_file.get_value ("Audio", "music", 1.0)
	sound_player.bus_volume = config_file.get_value ("Audio", "sound", 1.0)
	save_config ()	# Save the settings anyway (to be sure).
	return

func save_config () -> void:
	var config_ok = null
	config_file.set_value ("Graphics", "fullscreen", OS.window_fullscreen)
	config_file.set_value ("Audio", "master", db2linear (helper_functions.master_bus_volume))
	config_file.set_value ("Audio", "music", db2linear (music_player.bus_volume))
	config_file.set_value ("Audio", "sound", db2linear (sound_player.bus_volume))
	config_ok = config_file.save (CONFIG_FILENAME)	# Save the config.
	if (not config_ok == OK):	# If something does go wrong, though, say so.
		printerr ("ERROR: save_config couldn't save the config file! Error code ", config_ok, ".")
	return
