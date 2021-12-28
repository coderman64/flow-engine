### Flow Engine
# Coderman64 2021.

# FIXME: 8 appears to be a "magic number", find out what it's referring to, turn it into a variable.
# FIXME: Gravity, acceleration etc. are a bunch of "magic numbers" that need more explanation.

extends "res://Scripts/Player/player_generic.gd"

func _ready () -> void:
	# put all child particle systems in parts except for the grind particles
	for i in get_children ():
		if i is Particles2D and not i == grindParticles:
			parts.append (i)

	# set the start position and layer
	start_position = position
	startLayer = collision_layer
	setCollisionLayer (false)

	# set the trail length to whatever the boostLine's size is.
	TRAIL_LENGTH = boost_line.points.size ()

	# reset all game values
	reset_character ()
	return

func process_boost () -> void:
	# handles the boosting controls

	if (is_boosting == 1 and hud_boost.value > 0):
		# setup the boost when the player first presses the boost button

		is_boosting += 1

		# reset the boost line points
		for i in range (0, TRAIL_LENGTH):
			boost_line.points [i] = Vector2.ZERO

		# play the boost sfx
		boost_sound.stream = boost_sfx
		boost_sound.play ()

		# set the camera smoothing to the initial boost lag
		cam.set_follow_smoothing (BOOST_CAM_LAG)

		# stop moving vertically as much if you are in the air (air boost)
		if (state == -1 and player_velocity.x < ACCELERATION):
			player_velocity.x = BOOST_SPEED * (1 if player_sprite.flip_h else -1)
			player_velocity.y = 0

		voice_sound.play_effort ()
		return

	if (is_boosting > 1 and hud_boost.value > 0):
		# linearly interpolate the camera's "boost lag" back down to the normal (non-boost) value
		cam.set_follow_smoothing (lerp (cam.get_follow_smoothing (), DEFAULT_CAM_LAG, CAM_LAG_SLIDE))

		if (is_grinding):
			# apply boost to a grind
			grindVel = BOOST_SPEED * (1 if player_sprite.flip_h else -1)
		elif (state == 0):
			# apply boost if you are on the ground
			ground_velocity = BOOST_SPEED * (1 if player_sprite.flip_h else -1)
		elif (game_space.angle_distance (player_velocity.angle (), 0) < PI/3 or game_space.angle_distance (player_velocity.angle (), PI) < PI/3):
			# apply boost if you are in the air (and are not going straight up or down
			player_velocity = player_velocity.normalized ()*BOOST_SPEED
		else:
			# if none of these situations fit, you shouldn't be boosting here!
			is_boosting = 0

		# set the visibility and rotation of the boost line and sprite
		boost_sprite.visible = true
		boost_sprite.rotation = player_velocity.angle () - rotation
		boost_line.visible = true
		boost_line.rotation = -rotation

		# decrease boost value while boosting
		game_space.change_boost_value (-0.06)
	else:
		# the camera lag should be normal while not boosting
		cam.set_follow_smoothing (DEFAULT_CAM_LAG)

		# stop the boost sound, if it is playing
		if (boost_sound.stream == boost_sfx):
			boost_sound.stop ()

		# disable all visual boost indicators
		boost_sprite.visible = false
		boost_line.visible = false

		# We're not boosting, so set boosting counter to zero.
		is_boosting = 0
	return

func process_air () -> void:
	# handles physics while the player is in the air

	# apply gravity
	player_velocity = Vector2 (player_velocity.x, player_velocity.y+GRAVITY)

	# get the angle of the point for the left and right floor raycasts
	langle = game_space.angle_limit (-atan2 (LeftCast.get_collision_normal ().x, LeftCast.get_collision_normal ().y)-PI)
	rangle = game_space.angle_limit (-atan2 (RightCast.get_collision_normal ().x, RightCast.get_collision_normal ().y)-PI)

	# calculate the average ground rotation (averaged between the points)
	avgGRot = (langle+rangle)/2

	# set a default avgGPoint
	avgGPoint = Vector2.INF

	# Calculate the average ground point.
	if (LeftCast.is_colliding () and RightCast.is_colliding ()):	# Both colliders hitting something.
		var LeftCastPt = Vector2 (
			LeftCast.get_collision_point ().x + cos (rotation) * 8,
			LeftCast.get_collision_point ().y + sin (rotation) * 8)
		var RightCastPt = Vector2 (
			RightCast.get_collision_point ().x - cos (rotation) * 8,
			RightCast.get_collision_point ().y - sin (rotation) * 8)
		avgGPoint = (LeftCastPt if position.distance_to (LeftCastPt) < position.distance_to (RightCastPt) else RightCastPt)
	elif LeftCast.is_colliding ():	# Left collider only is hitting something.
		avgGPoint = Vector2 (LeftCast.get_collision_point ().x+cos (rotation)*8, LeftCast.get_collision_point ().y+sin (rotation)*8)
		avgGRot = langle
	elif RightCast.is_colliding ():	# Right collider only is hitting something.
		avgGPoint = Vector2 (RightCast.get_collision_point ().x-cos (rotation)*8, RightCast.get_collision_point ().y-sin (rotation)*8)
		avgGRot = rangle

	# calculate the average ceiling height based on the collision raycasts.
	if (LeftCastTop.is_colliding () and RightCastTop.is_colliding ()):	# Both colliders hitting something.
		avgTPoint = Vector2 (
			(LeftCastTop.get_collision_point ().x+RightCastTop.get_collision_point ().x)/2,
			(LeftCastTop.get_collision_point ().y+RightCastTop.get_collision_point ().y)/2)
	elif LeftCastTop.is_colliding ():	# Left collider only.
		avgTPoint = Vector2 (LeftCastTop.get_collision_point ().x+cos (rotation)*8, LeftCastTop.get_collision_point ().y+sin (rotation)*8)
	elif RightCastTop.is_colliding ():	# Right collider only.
		avgTPoint = Vector2 (RightCastTop.get_collision_point ().x-cos (rotation)*8, RightCastTop.get_collision_point ().y-sin (rotation)*8)

	# handle collision with the ground
	if (abs (avgGPoint.y-position.y) <= collider_height):
		print_debug ("Ground hit at ", position)
		state = 0
		rotation = avgGRot
		player_sprite.rotation = 0
		ground_velocity = sin (rotation) * (player_velocity.y+0.5) + cos (rotation) * player_velocity.x

		# If you were stomping, play the sound and stop stomping.
		if (is_stomping):
			boost_sound.stream = stomp_land_sfx
			boost_sound.play ()
			is_stomping = false

	# air-based movement
	if (abs (player_velocity.x) < 16):
		player_velocity = Vector2 (player_velocity.x+(AIR_ACCEL * movement_direction), player_velocity.y)

	### STOMPING CONTROLS ###

	# initiating a stomp
	if (is_stomping):

		# set the animation state
		change_player_animation ("Roll")
		rotation = 0
		player_sprite.rotation = 0

		# clear all points in the boostLine rendered line
		for i in range (0, TRAIL_LENGTH):
			boost_line.points [i] = Vector2.ZERO

		# play sound
		boost_sound.stream = stomp_sfx
		boost_sound.play ()

	# for every frame while a stomp is occuring...
	if (is_stomping):
		player_velocity = Vector2 (max (-MAX_STOMP_XVEL, min (MAX_STOMP_XVEL, player_velocity.x)), STOMP_SPEED)

		# make sure that the boost sprite is not visible
		boost_sprite.visible = false

		# manage the boost line
		boost_line.visible = true
		boost_line.rotation = -rotation
	else:
		process_boost ()	# Boost is only processed when not stomping.

	# slowly slide the player's rotation back to zero as you fly through the air
	player_sprite.rotation = lerp (player_sprite.rotation, 0, 0.1)

	# handle left and right sideways collision (respectively)
	if (LSideCast.is_colliding () and LSideCast.get_collision_point ().distance_to (position+player_velocity) < (collider_radius + 4) and player_velocity.x < 0):
		player_velocity = Vector2 (0, player_velocity.y)
		position = LSideCast.get_collision_point () + Vector2 ((collider_radius + 4), 0)
		is_boosting = 0
	if (RSideCast.is_colliding () and RSideCast.get_collision_point ().distance_to (position+player_velocity) < (collider_radius + 4) and player_velocity.x > 0):
		player_velocity = Vector2 (0, player_velocity.y)
		position = RSideCast.get_collision_point () - Vector2 ((collider_radius + 4), 0)
		is_boosting = 0

	# top collision
	if (avgTPoint.distance_to (position+player_velocity) <= collider_height):
		player_velocity = Vector2 (player_velocity.x, 0)

	# Allow the player to change the duration of the jump by releasing the jump
	# button early
	if ((not is_jumping) and can_jump_short):
		player_velocity = Vector2 (player_velocity.x, max (player_velocity.y, -JUMP_SHORT_LIMIT))

	# ensure the proper speed of the animated sprites
	player_sprite.speed_scale = 1
	return

func process_ground () -> void:
	# calculate the ground rotation for the left and right raycast colliders, respectively
	langle = game_space.angle_limit (-atan2 (LeftCast.get_collision_normal ().x, LeftCast.get_collision_normal ().y)-PI)
	rangle = game_space.angle_limit (-atan2 (RightCast.get_collision_normal ().x, RightCast.get_collision_normal ().y)-PI)

	# calculate the average ground rotation
	if abs (langle-rangle) < PI:
		avgGRot = game_space.angle_limit ((langle+rangle)/2)
	else:
		avgGRot = game_space.angle_limit ((langle+rangle+PI*2)/2)

	# Calculate the average ground level based on the available colliders. Rotation is set if left/right colliders are
	# colliding, but not both.
	if (LeftCast.is_colliding () and RightCast.is_colliding ()):	# Both colliders are colliding.
		avgGPoint = Vector2 ((LeftCast.get_collision_point ().x+RightCast.get_collision_point ().x)/2, (LeftCast.get_collision_point ().y+RightCast.get_collision_point ().y)/2)
	elif LeftCast.is_colliding ():	# Left collider only.
		avgGPoint = Vector2 (LeftCast.get_collision_point ().x+cos (rotation)*8, LeftCast.get_collision_point ().y+sin (rotation)*8)
		avgGRot = langle
	elif RightCast.is_colliding ():	# Right collider only.
		avgGPoint = Vector2 (RightCast.get_collision_point ().x-cos (rotation)*8, RightCast.get_collision_point ().y-sin (rotation)*8)
		avgGRot = rangle

	# set the rotation and position of the player to snap to the ground.
	rotation = avgGRot
	position = Vector2 (avgGPoint.x + 20 * sin (rotation), avgGPoint.y - 20 * cos (rotation))

	if (not is_rolling):
		# handle rightward acceleration
		if movement_direction > 0 and ground_velocity < MAX_SPEED:
			ground_velocity = ground_velocity + ACCELERATION
			# "skid" mechanic, to more quickly accelerate when reversing
			# (this makes the player feel more responsive)
			if ground_velocity < 0:
				ground_velocity = ground_velocity + SKID_ACCEL

		# handle leftward acceleration
		elif movement_direction < 0 and ground_velocity > -MAX_SPEED:
			ground_velocity = ground_velocity - ACCELERATION

			# "skid" mechanic (see rightward section)
			if ground_velocity > 0:
				ground_velocity = ground_velocity - SKID_ACCEL
		else:
			# general deceleration and stopping if no key is pressed
			# declines at a constant rate
			if not ground_velocity == 0:
				ground_velocity -= SPEED_DECAY * (ground_velocity/abs (ground_velocity))
			if abs (ground_velocity) < SPEED_DECAY*1.5:
				ground_velocity = 0
	else:
		# general deceleration and stopping if no key is pressed
		# declines at a constant rate
		if not ground_velocity == 0:
			ground_velocity -= (SPEED_DECAY * (ground_velocity/abs (ground_velocity)) * 0.3)
		if (abs (ground_velocity) < (SPEED_DECAY * 1.5)):
			ground_velocity = 0

	# left and right wall collision, respectively
	if (LSideCast.is_colliding () and LSideCast.get_collision_point ().distance_to (position) < (collider_height+1) and ground_velocity < 0):
		ground_velocity = 0
		position = LSideCast.get_collision_point () + Vector2 (position.x-LSideCast.get_collision_point ().x, position.y-LSideCast.get_collision_point ().y).normalized () * (collider_height + 1)
		is_boosting = 0
	if (RSideCast.is_colliding () and RSideCast.get_collision_point ().distance_to (position) < (collider_height+1) and ground_velocity > 0):
		ground_velocity = 0
		position = RSideCast.get_collision_point () + Vector2 (position.x-RSideCast.get_collision_point ().x, position.y-RSideCast.get_collision_point ().y).normalized () * (collider_height + 1)
		is_boosting = 0

	# apply gravity if you are on a slope, and apply the ground velocity
	ground_velocity += sin (rotation) * GRAVITY
	player_velocity = Vector2 (cos (rotation) * ground_velocity, sin (rotation) * ground_velocity)

	# enter the air state if you run off a ramp, or walk off a cliff, or something
	if (not avgGPoint.distance_to (position) < (collider_height+1) or not (LeftCast.is_colliding () and RightCast.is_colliding ())):
		state = -1
		player_sprite.rotation = rotation
		rotation = 0
		is_rolling = false

	# If your speed isn't high enough you'll fall off walls.
	if (abs (rotation) >= PI/3 and (abs (ground_velocity) < 0.2 or (not ground_velocity == 0 and not previous_ground_velocity == 0 and not ground_velocity/abs (ground_velocity) == previous_ground_velocity/abs (previous_ground_velocity)))):
		state = -1
		player_sprite.rotation = rotation
		rotation = 0
		position = Vector2 (position.x-sin (rotation)*2, position.y+cos (rotation)*2)
		is_rolling = false

	# set the player's sprite based on his ground velocity
	if (not is_rolling):
		if (abs (ground_velocity) > threshold_run_fast):
			change_player_animation ("Run4")
		elif (abs (ground_velocity) > threshold_run_slow):
			change_player_animation ("Run3")
		elif (abs (ground_velocity) > threshold_jog):
			change_player_animation ("Run2")
		elif (abs (ground_velocity) > threshold_walk):
			change_player_animation ("Walk")
		elif (not is_crouching):
			change_player_animation ("idle")
	else:
		change_player_animation ("Roll")

	if (abs (ground_velocity) > threshold_walk):
		is_crouching = false
		player_sprite.speed_scale = 1
	else:
		ground_velocity = 0
		is_rolling = false

	if (is_crouching and abs (ground_velocity) <= threshold_walk):
		change_player_animation ("Crouch")
		player_sprite.speed_scale = 1
		if player_sprite.frame > 3:
			player_sprite.speed_scale = 0
	elif is_crouching:
		change_player_animation ("Crouch")
		player_sprite.speed_scale = 1
		if player_sprite.frame >= 6:
			player_sprite.speed_scale = 1
			is_crouching = false

	# Process boost.
	process_boost ()

	# jumping
	if (is_jumping and not is_crouching and (not is_boosting)):
		if (not can_jump_short):
			state = -1
			player_velocity = Vector2 (player_velocity.x+sin (rotation)*JUMP_VELOCITY, \
				player_velocity.y-cos (rotation)*JUMP_VELOCITY)
			player_sprite.rotation = rotation
			rotation = 0
			change_player_animation ("Roll")
			can_jump_short = true
			is_rolling = false
			sound_player.play_sound ("player_jump")
	else:
		can_jump_short = false

	if ((is_jumping and is_crouching) or is_spindashing):
		is_spindashing = true
		change_player_animation ("Spindash")
		player_sprite.speed_scale = 1
		if (not is_crouching):
			ground_velocity = 15 * (1 if player_sprite.flip_h else -1)
			is_spindashing = false
			is_rolling = true

	# set the previous ground velocity and last rotation for next frame
	previous_ground_velocity = ground_velocity
	lRot = rotation
	return

func _physics_process (_delta) -> void:
	# calculate the player's physics, controls, and all that fun stuff
	if (invincible > 0):	# Invincible? If so, run the counter down.
		invincible -= 1
		player_sprite.modulate = Color (1, 1, 1, 1 - (invincible % 30) / 30.0)
	else:
		hurt = false

	if (not is_grinding and rail_sound.playing):
		rail_sound.stop ()	# If you're not grinding on a rail, then the rail sound should not be playing.

	grindParticles.emitting = is_grinding	# Grinding particles depend on if the player is grinding or not.

	# run the correct function based on the current air/ground state
	if (is_grinding):
		if (is_tricking):
			change_player_animation ("railTrick")
			player_sprite.speed_scale = 1
			if (player_sprite.frame > 0):
				stop_while_tricking = true
			if (player_sprite.frame <= 0 and stop_while_tricking):
				is_tricking = false
				var part = boostParticle.instance ()
				part.position = position
				part.boostValue = 2
				get_node ("/root/Level").add_child (part)
		else:
			change_player_animation ("Grind")

		if (is_stomping and not is_tricking):
			is_tricking = true
			stop_while_tricking = false
			voice_sound.play_effort ()

		grindHeight = player_sprite.frames.get_frame (player_sprite.animation, player_sprite.frame).get_height () / 2

		grindOffset += grindVel
		var dirVec = grindCurve.interpolate_baked (grindOffset+1)-grindCurve.interpolate_baked (grindOffset)
		rotation = dirVec.angle ()
		position = grindCurve.interpolate_baked (grindOffset)\
			+Vector2.UP*grindHeight*cos (rotation)+Vector2.RIGHT*grindHeight*sin (rotation)\
			+grindPos

		rail_sound.pitch_scale = lerp (RAILSOUND_MINPITCH, RAILSOUND_MAXPITCH, abs (grindVel)/BOOST_SPEED)
		grindVel += sin (rotation)*GRAVITY

		if (dirVec.length () < 0.5 or \
			(grindCurve.interpolate_baked (grindOffset-1) == \
			grindCurve.interpolate_baked (grindOffset))):
			state = -1
			is_grinding = false
			is_tricking = false
			stop_while_tricking = false
			rail_sound.stop ()
		else:
			player_velocity = dirVec*grindVel

		if (is_jumping and not is_crouching):
			if (not can_jump_short):
				state = -1
				player_velocity = Vector2 (player_velocity.x + sin (rotation) * JUMP_VELOCITY, \
					player_velocity.y - cos (rotation) * JUMP_VELOCITY)
				player_sprite.rotation = rotation
				rotation = 0
				change_player_animation ("Roll")
				can_jump_short = true
				is_rolling = false
				is_grinding = false
				is_tricking = false
				stop_while_tricking = false
				rail_sound.stop ()
		else:
			can_jump_short = false
		process_boost ()
	elif (state == -1):
		process_air ()
		is_rolling = false
	elif (state == 0):
		process_ground ()

	# update the boost line
	for i in range (0, TRAIL_LENGTH - 1):
		boost_line.points [i] = (boost_line.points [i + 1] - player_velocity + (last_position - position))
	boost_line.points [TRAIL_LENGTH-1] = Vector2.ZERO
	if (is_stomping):
		boost_line.points [TRAIL_LENGTH - 1] = Vector2 (0, 8)

	# apply the character's velocity, no matter what state the player is in.
	position = Vector2 (position.x+player_velocity.x, position.y+player_velocity.y)
	last_position = position

	if (parts):
		for i in parts:
			i.process_material.direction = Vector3 (player_velocity.x, player_velocity.y, 0)
			i.process_material.initial_velocity = player_velocity.length ()*20
			i.rotation = -rotation

	# ensure the player is facing the right direction
	player_sprite.flip_h = (false if movement_direction < 0 and player_velocity.x < 0.0 else \
		(true if movement_direction > 0 and player_velocity.x > 0.0 else player_sprite.flip_h))

	return

## _on_Rail_area_entered
# This function is run whenever the player hits a rail. Starts or continues grinding on the rail.
func _on_Rail_area_entered (area, curve, origin) -> void:
	if (is_grinding):	# If you're already grinding, continue with that.
		return

	if (self == area and player_velocity.y > 0):	# Start grinding.
		is_grinding = true
		grindCurve = curve
		grindPos = origin
		grindOffset = grindCurve.get_closest_offset (position-grindPos)
		grindVel = player_velocity.x

		rail_sound.play ()

		if (is_stomping):	# Landing after stomping.
			boost_sound.stream = stomp_land_sfx
			boost_sound.play ()
			is_stomping = false
	return
