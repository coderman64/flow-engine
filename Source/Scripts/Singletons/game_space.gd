### game_space.gd
# Game-related variables and functions that don't belong to any one thing go in here.
# NOTE: Some functions depend upon things being loaded to work, e.g. the HUD.

extends Node

var lives:int = 3 setget set_lives						# How many lives until game over?
var rings_collected:int = 0 setget set_rings			# Rings (collectibles) the player has.
var real_rings_collected:int = 0						# Collectibles the player REALLY has.
var score:int = 0 setget set_score						# What's the score?
var timer:Vector2 = Vector2.ZERO						# x represents seconds, y minutes.
onready var last_checkpoint = null						# What is the last checkpoint.

onready var player_class = preload ("res://Scripts/Player/player_generic.gd")	# Convenience for checking player stuff.
onready var enemy_class = preload ("res://Scripts/Enemies/enemy_generic.gd")	# Convenience for checking enemies.
# Used for when the actual physical node of the player, rather than the player class, is required.
var player_node = null	# Set up by player_generic.gd - trying to use this before then will result in bad things happening!

# Cheating flags!
export(bool) var infinite_boost_cheat = false	# Can boost forever?
export(bool) var invincibility_cheat = false	# Can never take damage?

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	helper_functions._whocares = $"level_timer".connect ("timeout", self, "on_level_timer_timeout")
	reset_game_space ()
	return

## reset_game_space
# For new games, or restarting a game. Resets lives, rings etc. all to their default values.
func reset_game_space () -> void:
	lives = 3
	rings_collected = 0
	real_rings_collected = 0
	score = 0
	timer = Vector2.ZERO
	last_checkpoint = null
	return

### MATHS-RELATED FUNCTIONS.

## angle_limit
# Returns the given angle as an angle (in radians) between -PI and PI
func angle_limit (ang:float) -> float:
	var sign1 := 1.0
	if (not ang == 0):
		sign1 = ang / abs (ang)
	ang = fmod (ang, PI * 2)
	if (abs (ang) > PI):
		ang = (2 * PI - abs (ang)) * sign1 * -1
	return (ang)

## angle_distance
# Returns the angle distance between rot1 and rot2, even over the 360deg mark.
# (i.e. 350 and 10 will be 20 degrees apart)
func angle_distance (rot1:float, rot2:float) -> float:
	rot1 = angle_limit (rot1)
	rot2 = angle_limit (rot2)
	if abs (rot1-rot2) > PI and rot1>rot2:
		return (abs (angle_limit (rot1) - (angle_limit (rot2) + PI * 2)))
	elif abs (rot1 - rot2) > PI and rot1 < rot2:
		return (abs ((angle_limit (rot1) + PI * 2)-(angle_limit (rot2))))
	else:
		return abs (rot1 - rot2)

### HUD FUNCTIONS.

## change_boost_value
# Use this everywhere to change the current boost value.
func change_boost_value (change_to: float) -> void:
	if (not has_node ("/root/Level/game_hud")):		# Make sure the game_hud is available!
		return
	$"/root/Level/game_hud/hud_boost".value += change_to
	return

## set_rings
# The setter for how many rings the player does (or doesn't) have (and really have).
func set_rings (value:int) -> void:
	if (not has_node ("/root/Level/game_hud")):		# Make sure the game_hud is available!
		return
	real_rings_collected += (-real_rings_collected if value < rings_collected else value - rings_collected)
	rings_collected = value
	$"/root/Level/game_hud/hud_rings/count".text = var2str (rings_collected)
	if (real_rings_collected >= 100):	# Over 100 rings means you get an extra life!
		real_rings_collected -= 100
		game_space.lives += 1
	# Ensure the "no rings" animation plays when required.
	if (rings_collected < 1 and not $"/root/Level/game_hud/hud_rings/AnimationPlayer".current_animation == "no_rings"):
		$"/root/Level/game_hud/hud_rings/AnimationPlayer".play ("no_rings")
	elif (rings_collected > 0 and not $"/root/Level/game_hud/hud_rings/AnimationPlayer".current_animation == "default"):
		$"/root/Level/game_hud/hud_rings/AnimationPlayer".play ("default")
	return

## on_level_timer_timeout
# This is called every second. It updates the timer display.
func on_level_timer_timeout () -> void:
	if (not has_node ("/root/Level/game_hud")):		# Make sure the game_hud is available!
		return
	timer.x += 1
	if (timer.x > 59):	# A minute has passed!
		timer.x = 0
		timer.y += 1
	$"/root/Level/game_hud/hud_timer/count".text = var2str (int (timer.y)).pad_zeros (2) + ":" + var2str (int (timer.x)).pad_zeros(2)
	return

## set_score
# Sets the player score.
func set_score (value):
	if (not has_node ("/root/Level/game_hud")):		# Make sure the game_hud is available!
		return
	score = value
	$"/root/Level/game_hud/hud_score/count".text = var2str (score)
	return

## set_lives
# Basically, this function does these:
# If the player has more lives, run the extra life stuff.
# If less, the death animation/reset to checkpoint/etc.
# If none, game over.
func set_lives (value:int) -> void:
	if (not has_node ("/root/Level/game_hud")):		# Make sure the game_hud is available!
		return
	if (value < lives):				# Lost a life!
		sound_player.play_sound ("player_death")
		player_node.reset_character ()
	elif (value > lives):			# Extra life time...
		helper_functions._whocares = jingle_player.play_jingle ("res://Assets/Audio/Jingles/Extra_Life.ogg")
	lives = value
	if (lives < 0):					# No lives left? It's game over.
		player_node.reset_game ()
	$"/root/Level/game_hud/hud_lives/count".text = var2str (lives)
	return
