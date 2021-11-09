### "Helper" functions should be kept in here.
# These can be anything, from displaying error messages to changing scenes.
# These should not usually be directly related to gameplay/application use.
# This also controls the volume for the master audio bus.

extends Node

onready var root := get_tree ().get_root ()	# What the root of the scene tree is.

var _whocares = null	# Used for functions which return a value which we don't need to be concerned with.

# Used for the master audio bus.
onready var master_bus_index := AudioServer.get_bus_index ("Master")
onready var master_bus_volume = AudioServer.get_bus_volume_db (master_bus_index) setget set_master_bus_volume

# do_once_only uses this dictionary.
onready var do_once_dictionary = {
	NULL_DO_ONCE = "DO_NOT_DELETE",	# Keep me here!
}

onready var cli_args = Array (OS.get_cmdline_args ())	# An array of any command-line arguments passed.

func _ready () -> void:
	print_debug (cli_args.size (), " command line argument/s: ", cli_args)
	Engine.target_fps = 60
	return

## _input
# Don't put too much in here, otherwise performance will suffer. Use this for certain actions that are not
# dependent upon scenes (e.g., toggling full screen mode).
# Use "is_action_just_pressed" here to avoid input run-on problems.
func _input (_event) -> void:
	if (Input.is_action_just_pressed ("toggle_full_screen")):	# Toggle full-screen mode.
		print_debug ("Toggling fullscreen ", ("off" if OS.window_fullscreen else "on"), ".")
		OS.window_fullscreen = not OS.window_fullscreen
	return

## add_child_to_node
# helper_functions.add_child_to_node (scene_instance, node_to_add_to)
# Adds an (instanced!) scene (scene_instance) as a child to the given node (node_to_add_to).
# This neither creates an instance nor frees it, so you need to do those before/after calling this function.
# It also does no error checking, so pass wrong things and/or in the wrong order and things will break.
func add_child_to_node (scene_instance = null, node_to_add_to = "/root") -> void:
	# Don't expect this to work properly if you forget to create an *instance* of the scene to pass!
	get_node (node_to_add_to).call_deferred ("add_child", scene_instance)
	return

## add_path_to_node
# helper_functions.add_path_to_node (scene_path, node_to_add_to)
# Adds an instance of the scene specified by scene_path to the desired node (node_to_add_to).
# You should specify the path as absolute wherever possible.
# Returns the instance created, or null if the path provided is not valid.
func add_path_to_node (scene_path = "", node_to_add_to = "/root"):
	var scene_to_go_to = ResourceLoader.load (scene_path)	# Load and...
	if (scene_to_go_to == null):								# ...check that the path/scene is valid...
		printerr ("ERROR: add_path_to_node cannot use ", scene_path, "; it is not a valid or existing scene!")
		return (null)
	scene_to_go_to = scene_to_go_to.instance ()					# ...create an instance of the scene.
	# Then add it to the specified node.
	call_deferred ("add_child_to_node", scene_to_go_to, node_to_add_to)
	return (scene_to_go_to)										# Return the instance created.

## change_scene
# helper_functions.change_scene (path)
# Goes to the relevant scene; the scene is a path, so "res://<filename>".
# You should specify the path as absolute wherever possible.
# Returns the error codes given for change_scene_to (0 for OK, non-zero otherwise).
func change_scene (scene_path) -> int:
	var new_scene = ResourceLoader.load (scene_path)		# Load and...
	if (new_scene == null):									# ...check that the path/scene is valid...
		printerr ("ERROR: change_scene cannot use ", scene_path, "; it is not a valid or existing scene file!")
		return (ERR_FILE_NOT_FOUND)
	get_tree ().current_scene.queue_free ()
	return (get_tree ().change_scene_to (new_scene))		# ...change to the new scene (or not...).

## do_once_only
# helper_functions.do_once_only (do_me)
# Does something once only (if do_me given isn't in the dictionary for do_once_only). After that, it gets
# added so it won't do it again.
# Returns true first time round (because it hadn't been done before!), false afterwards.
# Shouldn't make too much of an adverse impact on performance if used carefully
# (i.e., avoid using in _*process functions).
# This is an exception to "should not usually be directly related to gameplay/application use".
func do_once_only (do_me) -> bool:
	if (do_once_dictionary.has (do_me)):	# Already been done once?
		print_debug (do_me, " has already been done.")
		return (false)					# If so, returns false as it has already been done before.
	# Not been done, so add it to the dictionary and return true.
	print_debug (do_me, " has now been done.")
	do_once_dictionary [do_me] = "I_AM_DONE"
	return (true)

## value_in_range
# helper_functions.value_in_range (check_value, range_start, range_end)
# Checks to see if <check_value> falls between <range_start> and <range_end>.
# Returns true (it is) or false (it isn't; either because it is outside the range or function error).
func value_in_range (check_value, range_start, range_end) -> bool:
	if (range_start >= range_end):
		printerr ("ERROR: value_in_range cannot use ", range_start, "; it must be less than ", range_end, ".")
		return (false)
	return (check_value >= range_start and check_value <= range_end)

## set_master_bus_volume
# Adjusts the master bus volume.
func set_master_bus_volume (value) -> void:
	value = clamp (value, 0.0, 1.0)	# Ensure sanity prevails.
	AudioServer.set_bus_volume_db (master_bus_index, linear2db (value))
	master_bus_volume = AudioServer.get_bus_volume_db (master_bus_index)
	return
