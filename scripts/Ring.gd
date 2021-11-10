"""
controls a typical (non-flying) ring
"""

extends Area2D

# true if the ring has been collected 
var collected = false

# holds a reference to the AnimatedSprite node for the ring
var sprite

# holds a referene to the AudioStreamPlayer for the ring
var audio

var boostBar

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("AnimatedSprite")
	audio = get_node("AudioStreamPlayer")

# if the sprite has been collected, remove all visibility once the sparkle 
# animation finishes
func _process(_delta):
	if collected and sprite.animation == "Sparkle" and \
		sprite.frame >= 6:
		visible = false


func _on_Ring_area_entered(area):
	# collide with the player, if the ring has not yet been collected
	if not collected and area.name == "Player":
		collected = true
		sprite.animation = "Sparkle"
		audio.play();
		get_node("/root/Node2D/CanvasLayer/RingCounter").addRing()
		get_node("/root/Node2D/CanvasLayer/boostBar").changeBy(2)
