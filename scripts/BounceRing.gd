"""
this script is for the bouncy-type rings that fly out of you when you get hit
"""

extends Area2D


# true if the ring has been collected 
var collected = false

# stores a reference to the raycast node
var downCast
# holds a reference to the AnimatedSprite node for the ring
var sprite
# holds a referene to the AudioStreamPlayer for the ring
var audio

# holds a reference to the boost bar
var boostBar

# timer variable to keep track of when the ring disappears.
var collectionStartTimer = 120

# represents the current velocity of the ring.
export(Vector2) var velocity1 = Vector2(0,0)


func _ready():
	# grab all the relevent nodes on startup
	sprite = get_node("AnimatedSprite")
	audio = get_node("AudioStreamPlayer")
	downCast = get_node("DownCast")


func _process(_delta):
	# make the sprite invisible once the ring has been collected and
	# the sparkle animation is over
	if collected and sprite.animation == "Sparkle" and \
		sprite.frame >= 6:
		visible = false

func _physics_process(_delta):
	
	# count down the timer
	collectionStartTimer -= 1
	
	if not collected:
		# bounce on relevent ground nodes
		if downCast.is_colliding() and downCast.get_collision_point().y < position.y + 16:
			velocity1.y *= -1
			
		# add gravity
		velocity1.y += 0.02
		
		# apply velocity 
		position += velocity1
	
	# once the timer gets to a certain point, start flashing the ring sprite
	if collectionStartTimer < -900:
		sprite.modulate = Color(1,1,1,1-(-collectionStartTimer%30)/30.0)
	
	# remove the ring node once the timer is up
	if collectionStartTimer < -1080:
		queue_free()

func _on_Ring_area_entered(area):
	
	# if the ring hasn't been collected and the player collides...
	if not collected and area.name == "Player" and collectionStartTimer <= 0:
		collected = true					# set collected to true
		sprite.animation = "Sparkle"		# set the animation to the sparkle
		audio.play();						# play the ring sfx
		get_node("/root/Node2D/CanvasLayer/RingCounter").addRing()	# add a ring to the total
