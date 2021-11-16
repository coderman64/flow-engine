### boost_particle.gd
# Boost "particles" are the "remains" of things that add to the players's boost score.
# They move towards the player, getting faster depending on time taken and player position.
# Once they get close enough to the player's position, boost is added to and the particle removed.

extends Node2D

var initial_velocity := Vector2.ZERO

export(float) var boostValue = 2	# How much is this particle going to add to the player's boost?

onready var hud_boost = get_node ("/root/Level/game_hud/hud_boost")

onready var line = get_node ("Line2D")
var lineLength := 30

var speed := 10.0

var oPos := Vector2.ZERO
var last_position := Vector2.ZERO

var timer := 0.0

# Calculate initial velocity, and how "long" the particles are.
func _ready () -> void:
	initial_velocity = Vector2 (random_helpers.RNG.randf ()-0.5, random_helpers.RNG.randf ()-0.5).normalized () * speed

	oPos = position
	last_position = oPos

	for i in range (lineLength):
		line.points [i] = Vector2.ZERO
	return

func _process (delta) -> void:
	if (timer < 1):		# Run the boost particle timer.
		timer += delta
	else:				# Accelerate the particle's speed.
		timer = 1
		speed += delta * 10

	position = oPos.linear_interpolate (game_space.player_node.position, timer)

	oPos += initial_velocity

	for i in range (lineLength-1, 0, -1):
		line.points [i] = line.points [i-1] - (position-last_position)

	line.points [0] = Vector2.ZERO

	if (timer >= 1 and position.distance_to (game_space.player_node.position) <= speed):
		# Close enough? Remove the particle, add to boost.
		game_space.change_boost_value (boostValue)
		queue_free ()

	last_position = position
	return
