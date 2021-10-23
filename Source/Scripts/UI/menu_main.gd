### menu_main
# The "main menu" of the project is controlled from here.
# By default it has three buttons - "New Game", "Options" and "Quit Game".
# Adjust to taste.

extends VBoxContainer

func _ready () -> void:
	# Connect the buttons to functions, set the keyboard focus on the "new game" button.
	helper_functions._whocares = $"btnNewGame".connect ("pressed", self, "btnNewGame_on_press")
	helper_functions._whocares = $"btnOptions".connect ("pressed", self, "btnOptions_on_press")
	helper_functions._whocares = $"btnQuit".connect ("pressed", self, "btnQuit_on_press")
	$"btnNewGame".grab_focus ()
	return

## btnNewGame_on_press
# Starts a new game!
func btnNewGame_on_press () -> void:
	if (not helper_functions.change_scene ("res://Scenes/Levels/chaos_festival.tscn") == OK):
		printerr ("Unable to load the test level!")
		get_tree ().quit ()
	return

## btnOptions_on_press
# Shows the main options.
func btnOptions_on_press () -> void:
	helper_functions.add_path_to_node ("res://Scenes/UI/menu_options.tscn", "/root/main_menu")
	yield (get_tree (), "idle_frame")		# And make sure they're added before continuing...
	$".".visible = false
	return

## btnQuit_on_press
# Quit the game.
func btnQuit_on_press () -> void:
	get_tree ().quit ()
	return
