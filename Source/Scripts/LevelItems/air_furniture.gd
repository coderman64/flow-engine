# controls "air furniture", such as springs, boost rings etc.

extends Area2D

# how strong is the spring?
export(float) var STRENGTH = 7
# does the spring force the player to go in the direction it is facing?
export(bool) var DIRECTED = false
# add a scaling effect (usually for boost rings)
export(bool) var furniture_scaling = false

onready var animation = find_node ("AnimatedSprite")	# stores the animated sprite
onready var sound = find_node ("AudioStreamPlayer")		# stores the audio stream player
var scaling := 1.0										# stores the current scale of the spring

func _ready () -> void:
	helper_functions._whocares = self.connect ("area_entered", self, "_on_Area2D_area_entered")
	return

func _on_Area2D_area_entered (area) -> void:
	if (area is game_space.player_class):	# The player is colliding.

		# calculate what vector to launch the player in
		var launchVector := Vector2 (0, -STRENGTH).rotated (rotation)

		# If undirected, calculate how fast the player is moving perpendicularly to the spring.
		var sideVector = (Vector2.ZERO if DIRECTED else area.player_velocity.dot (launchVector.normalized ().rotated (PI / 2))\
				*launchVector.normalized ().rotated (PI / 2))

		# Calculate the final vector to throw the player in.
		var finalVector = sideVector + launchVector

		# DEBUGGING ONLY: print out the values.
		print_debug ("sideVector: ", sideVector, " launchVector: ", launchVector, " finalVector: ", finalVector)

		# set the player's velocity to the final vector
		area.player_velocity = finalVector
		# set the player to the air state
		area.state = -1
		# The player didn't jump here...
		area.can_jump_short = false
		# set the player's position to this position
		area.position = position
		# if the player stomped on it, they are no longer stomping
		area.is_stomping = false

		# set the player's sprite rotation to their rotation
		area.find_node ("PlayerSprites").rotation = area.rotation
		# reset the player's rotation (this is typically how the player works in the air)
		area.rotation = 0

		# set the current animation frame to 0
		animation.frame = 0
		# play the attached sound
		sound.play ()
		# scale it (only applies if "furniture_scaling" is enabled)
		scaling = 2
	return

func _process (_delta) -> void:
	# set and lerp scale if furniture_scaling is enabled
	if (furniture_scaling):
		scale = Vector2 (scaling, scaling)
		scaling = lerp (scaling, 1, 0.1)
	return
