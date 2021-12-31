### player_generic.gd
# Contains the variables and functions all player characters will use.

extends Area2D

# audio streams for the player's various sound effects
export(AudioStream) var boost_sfx
export(AudioStream) var stomp_sfx
export(AudioStream) var stomp_land_sfx

# a reference to a bouncing ring prefab, so we can spawn a bunch of them when
# the player is hurt
export(PackedScene) var bounceRing
export(PackedScene) var boostParticle

# a list of particle systems for the player to control with his speed
# used for the confetti in the carnival level, or the falling leaves in leaf storm
var parts = []

# the player's ground state. 0 means he's on the ground, and -1 means he's in the
# air. This is not a boolean because of legacy code and stuff.
var state = -1

# the player's gravity
export(float) var GRAVITY = 0.3 / 4
# the player's acceleration on his own
export(float) var ACCELERATION = 0.15 / 4
# how much the player decelerates when skidding.
export(float) var SKID_ACCEL = 1
# the player's acceleration in the air.
export(float) var AIR_ACCEL = 0.1 / 4
# maximum speed under the player's own power
export(float) var MAX_SPEED = 20 / 2
# the speed of the player's boost. Generally just a tad higher than MAX_SPEED
export(float) var BOOST_SPEED = 25 / 2

# used to dampen the player's movement a little bit. Basically poor man's friction
export(float, 1) var SPEED_DECAY = 0.2 /2

# what velocity should the player jump at?
export(float) var JUMP_VELOCITY = 3.5
# what is the Velocity that the player should slow to when releasing the jump button?
export(float) var JUMP_SHORT_LIMIT = 1.5

# how fast (in pixels per 1/120th of a second) should the player stomp
export(float) var STOMP_SPEED = 20 / 2
# what is the limit to the player's horizontal movement when stomping?
export(float) var MAX_STOMP_XVEL = 2 / 2

# the speed at which the camera should typically follow the player
export(float) var DEFAULT_CAM_LAG = 20
# the speed at which the camera should follow the player when starting a boost
export(float) var BOOST_CAM_LAG = 0
# how fast the Boost lag should slide back to the default lag while boosting
export(float, 1) var CAM_LAG_SLIDE = 0.01

# how long is the player's boost/stomp trail?
var TRAIL_LENGTH = 40

# Capability flags. What can this character do?
export(bool) var can_boost := false		# Sonic, Blaze, Shadow etc. can boost their speed.
export(bool) var can_fly := false		# Tails, Cream etc. can fly.
export(bool) var can_glide := false		# Knuckles, Ray etc. can glide.

# state flags
var can_jump_short := false				# can the player shorten the jump?
var is_boosting := 0					# How long has the player been boosting?
var is_crouching := false
var is_flying := false
var is_gliding := false
var is_grinding := false
var is_jumping := false
var is_rolling := false
var is_spindashing := false
var is_stomping := false
var is_tricking := false
var is_unmoveable := false				# Used for cutscenes and other situations where the player shouldn't move.
var stop_while_tricking := false		# Is/can the player stop while tricking.

# Player's last position.
var last_position := Vector2.ZERO

# Speed thresholds for the player.
export(float) var threshold_walk = 0.02
export(float) var threshold_jog = 5/2
export(float) var threshold_run_slow = 10/2
export(float) var threshold_run_fast = 12/2

# flags and values for getting hurt
var hurt := false
var invincible := 0

# Movement strength/direction.
var movement_direction := 0.0

# grinding values.
var grindPos := Vector2.ZERO	# the origin position of the currently grinded rail
var grindOffset := 0.0		# how far along the rail (in pixels) is the player?
var grindCurve = null		# the curve that the player is currently grinding on
var grindVel := 0.0			# the velocity along the grind rail at which the player is currently moving
var grindHeight = 16		# how high above the rail is the center of the player's sprite?

# references to all the various raycasting nodes used for the player's collision with
# the map
onready var LeftCast = find_node ("LeftCast")
onready var RightCast = find_node ("RightCast")
onready var LSideCast = find_node ("LSideCast")
onready var RSideCast = find_node ("RSideCast")
onready var LeftCastTop = find_node ("LeftCastTop")
onready var RightCastTop = find_node ("RightCastTop")

# References to the player's physics collider. Its node, and height and radius.
onready var collider = find_node ("playerCollider")
onready var collider_radius = collider.shape.radius
onready var collider_height = collider.shape.height

# the player's sprites/renderers
onready var player_sprite = find_node ("PlayerSprites")		# the player's sprite
onready var boost_sprite = find_node ("BoostSprite")		# the sprite that appears over the player while boosting
onready var boost_line = find_node ("BoostLine")				# the line renderer for boosting and stomping

onready var hud_boost = get_node ("/root/Level/game_hud/hud_boost")	# Holds a reference to the boost UI bar.

onready var boost_sound = find_node ("sound_boost")	# the audio stream player with the boost sound
onready var rail_sound = find_node ("sound_rail")	# the audio stream player with the rail grinding sound
onready var voice_sound = find_node ("sound_voice")	# the audio stream player with the character's voices

# the minimum and maximum speed/pitch changes on the grinding sound
var RAILSOUND_MINPITCH = 0.5
var RAILSOUND_MAXPITCH = 2.0

onready var cam = find_node ("Camera2D")
onready var grindParticles = find_node ("GrindParticles")	# a reference to the particle node for griding

var avgGPoint := Vector2.ZERO			# average Ground position between the two foot raycasts
var avgTPoint := Vector2.ZERO			# average top position between the two head raycasts
var avgGRot := 0.0						# average ground rotation between the two foot raycasts
var langle := 0.0						# the angle of the left foot raycast
var rangle := 0.0						# the angle of the right foot raycast
var lRot := 0.0							# the player's rotation during the last frame
var start_position := Vector2.ZERO		# the position at which the player starts the level
var startLayer := 0.0					# the layer on which the player starts

var player_velocity := Vector2.ZERO		# the player's current velocity

var ground_velocity := 0.0				# the ground velocity
var previous_ground_velocity := 0.0		# the ground velocity during the previous frame

var backLayer := false					# whether or not the player is currently on the "back" layer

func _ready () -> void:
	$"/root/game_space/level_timer".start ()
	game_space.player_node = $"."	# Set the player_node in game_space to the ID of this node.
	if (has_node ("/root/Level/start_point")):	# We have a starting checkpoint!
		game_space.last_checkpoint = $"/root/Level/start_point"
		game_space.last_checkpoint.passed_checkpoint = true	# So it doesn't get triggered by mistake.
		game_space.last_checkpoint.visible = false			# In case the dev forgets!
		position = $"/root/Level/start_point".position
	else:
		printerr ("You shouldn't see this - did you forget to set start_point?")
		position = Vector2.ZERO
	return

# Generic input that all player character will use.
func _input (_event: InputEvent) -> void:
	if (not has_node ("/root/Level/game_hud")):
		return
	if (is_unmoveable):				# No player input wanted right now...
		movement_direction = 0		# ...so make sure the player's not moving.
		return
	if (Input.is_action_just_pressed ("toggle_pause")):	# Pause the game?
		helper_functions.add_path_to_node ("res://Scenes/UI/menu_options.tscn", "/root/Level/game_hud")
		yield (get_tree (), "idle_frame")		# And make sure they're added before continuing...
	# Movement direction can be anywhere between -1 (left) to +1 (right).
	movement_direction = (Input.get_action_strength ("move_right") - Input.get_action_strength ("move_left"))
	if (Input.is_action_pressed ("boost") and can_boost):	# So long as boost is held down, increase the counter.
		is_boosting += (1 if hud_boost.value > 0 else 0)
	else:									# No boosting, so reset to zero.
		is_boosting = 0
	is_stomping = (Input.is_action_just_pressed ("stomp") and not is_stomping)
	is_jumping = Input.is_action_pressed ("jump")
	is_crouching = Input.is_action_pressed ("crouch")
	if (OS.is_debug_build ()):	# DEBUGGING CONTROLS.
		if (Input.is_action_pressed ("restart")):	# Restart the game?
			reset_game ()
	return

## setCollisionLayer
# shortcut to change the collision mask for every raycast node connected to
# the player at the same time. Value is true for layer 1, false for layer 0
func setCollisionLayer (value) -> void:
	backLayer = value
	LeftCast.set_collision_mask_bit (0, not backLayer)
	LeftCast.set_collision_mask_bit (1, backLayer)
	RightCast.set_collision_mask_bit (0, not backLayer)
	RightCast.set_collision_mask_bit (1, backLayer)
	RSideCast.set_collision_mask_bit (0, not backLayer)
	RSideCast.set_collision_mask_bit (1, backLayer)
	LSideCast.set_collision_mask_bit (0, not backLayer)
	LSideCast.set_collision_mask_bit (1, backLayer)
	LeftCastTop.set_collision_mask_bit (0, not backLayer)
	LeftCastTop.set_collision_mask_bit (1, backLayer)
	RightCastTop.set_collision_mask_bit (0, not backLayer)
	RightCastTop.set_collision_mask_bit (1, backLayer)
	return

func _flipLayer (_body) -> void:
	# toggle between layers
	setCollisionLayer (not backLayer)
	return

func _layer0 (area) -> void:
	# explicitly set the collision layer to 0
	print_debug ("layer0: ", area.name)
	setCollisionLayer (false)
	return

func _layer1 (area) -> void:
	# explicitly set the collision layer to 1
	print_debug ("layer1: ", area.name)
	setCollisionLayer (true)
	return

## reset_game
# Resets the game, returns to the main menu.
func reset_game () -> void:
	reset_character ()
	game_space.reset_game_space ()
	game_space.get_node ("level_timer").stop ()
	if (not helper_functions.change_scene ("res://Scenes/UI/main_menu.tscn") == OK):
		printerr ("Unable to load the main menu!")
		get_tree ().quit ()
	music_player.stop_music ()
	return

## reset_character
# Resets your character ready for use. Sets rings to 0, speed to zero etc.
func reset_character () -> void:
	game_space.rings_collected = 0
	player_velocity = Vector2.ZERO
	state = -1
	if (not game_space.last_checkpoint == null):	# Passed a valid checkpoint, so go back to it.
		position = game_space.last_checkpoint.position
		# Rewind time to the time it was when the checkpoint was passed.
		game_space.timer = game_space.last_checkpoint.last_time
	else:
		printerr ("You shouldn't see this - did you forget to set start_point?")
		position = Vector2.ZERO
	setCollisionLayer (false)
	game_space.change_boost_value (-60)
	game_space.change_boost_value (20)
	invincible = 0
	is_unmoveable = false
	return

## is_player_attacking
# Is the player attacking something?
func is_player_attacking () -> bool:
	return (is_stomping or is_boosting > 0 or is_rolling or (player_sprite.animation == "Roll" and state == -1))

## hurt_player
# The player has been harmed, react accordingly.
func hurt_player () -> void:
	if (game_space.invincibility_cheat):	# Invincibility cheat is enabled, no harm no foul.
		return
	if (not invincible > 0):	# Set up being hurt!
		invincible = 120*5		# Counter for "blinking" temporary invunerability state.
		# Launch the player backwards.
		state = -1
		player_velocity = Vector2 (-player_velocity.x+sin (rotation) * JUMP_VELOCITY, \
			player_velocity.y-cos (rotation) * JUMP_VELOCITY)
		rotation = 0
		position += player_velocity*2

		# Make the hurt state obvious.
		change_player_animation ("hurt")
		voice_sound.play_hurt ()

		# If the player has any rings, bounce up to 32 of them.
		var t := 0
		var angle := 101.25
		var n := false
		var speed := 4.0
		var currentRing = null
		while (t < min (game_space.rings_collected, 32)):
			currentRing = bounceRing.instance ()
			currentRing.ring_velocity = Vector2 (-sin (angle) * speed, cos (angle) * speed)/2
			currentRing.position = position
			if (n):
				currentRing.ring_velocity.x *= -1
				angle += 22.5
			n = not n
			t += 1
			if (t == 16):
				speed = 2
				angle = 101.25
			get_node ("/root/Level").call_deferred ("add_child", currentRing)
		if (game_space.rings_collected > 0):	# Lose any rings collected.
			game_space.rings_collected = 0
			sound_player.play_sound ("lose_rings")
		else:									# No rings, so lose a life.
			game_space.lives -= 1
	return

## change_player_animation
# Changes the player character's animation.
func change_player_animation (new_anim) -> void:
	if (new_anim == player_sprite.animation):	# Don't "switch" to the same animation.
		return
	player_sprite.animation = new_anim
	return
