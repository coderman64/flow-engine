### Options screen.
# Pauses the game while up.
# The options are split up into tabs, nominally.
# Current options are:
# * Toggle fullscreen
# * Adjust master volume
# * Adjust music (and jingle) volume
# * Adjust sound volume
# Adjust to taste for specific games.

extends VBoxContainer

# Sets up the signals, makes sure the volume settings are correct and sets focus.
func _ready () -> void:
	helper_functions._whocares = $"btn_goback".connect ("pressed", self, "btn_mainmenu_on_press")
	helper_functions._whocares = $"options_tabholder/Options/btn_fullscreencheck".connect (
		"pressed",
		self,
		"on_btn_fullscreencheck_pressed"
	)
	helper_functions._whocares = $"options_tabholder/Options/volume_master/volume_master_slider".connect (
		"value_changed",
		self,
		"on_volume_master_slider_changed"
	)
	helper_functions._whocares = $"options_tabholder/Options/volume_music/volume_music_slider".connect (
		"value_changed",
		self,
		"on_volume_music_slider_changed"
	)
	helper_functions._whocares = $"options_tabholder/Options/volume_sound/volume_sound_slider".connect (
		"value_changed",
		self,
		"on_volume_sound_slider_changed"
	)
	$"options_tabholder/Options/volume_master/volume_master_slider".value = db2linear (
		AudioServer.get_bus_volume_db (helper_functions.master_bus_index)
	)
	$"options_tabholder/Options/volume_music/volume_music_slider".value = db2linear (
		AudioServer.get_bus_volume_db (music_player.bus_index)
	)
	$"options_tabholder/Options/volume_sound/volume_sound_slider".value = db2linear (
		AudioServer.get_bus_volume_db (sound_player.bus_index)
	)
	$"options_tabholder/Options/btn_fullscreencheck".pressed = OS.window_fullscreen
	$"btn_goback".grab_focus ()
	raise ()
	if (not has_node ("../menu_main")):	# Not being called from the main menu?
		$"header_text".text = "PAUSED"	# Then it must be being used as pause.
		get_tree ().paused = true	# Pause the rest of the game while the options screen is visible.
	return

# Returning to the previous. It saves any necessary changes.
func btn_mainmenu_on_press () -> void:
	if (has_node ("../menu_main")):	# If called from the main menu, make it visible again and give it focus.
		$"../menu_main".visible = true
		$"../menu_main/btnNewGame".grab_focus ()
	get_tree ().paused = false	# Unpause to allow everything to get moving again.
	config_helper.save_config ()
	queue_free ()
	return

# Toggle full-screen on or off.
func on_btn_fullscreencheck_pressed () -> void:
	OS.window_fullscreen = not OS.window_fullscreen
	return

# Changing the master bus volume.
func on_volume_master_slider_changed (value: float) -> void:
	helper_functions.master_bus_volume = value
	$"options_tabholder/Options/volume_master/Label".text = "Master Volume: "
	$"options_tabholder/Options/volume_master/Label".text += var2str (int (value * 100)).pad_zeros (3) + "%"
	return

# Adjusting the music and jingle volume.
func on_volume_music_slider_changed (value: float) -> void:
	music_player.bus_volume = value
	jingle_player.bus_volume = value
	$"options_tabholder/Options/volume_music/Label".text = "Music Volume:  "
	$"options_tabholder/Options/volume_music/Label".text += var2str (int (value * 100)).pad_zeros (3) + "%"
	return

# Changing the volume for the sound.
func on_volume_sound_slider_changed (value: float) -> void:
	sound_player.bus_volume = value
	$"options_tabholder/Options/volume_sound/Label".text = "Sound Volume:  "
	$"options_tabholder/Options/volume_sound/Label".text += var2str (int (value * 100)).pad_zeros (3) + "%"
	return
