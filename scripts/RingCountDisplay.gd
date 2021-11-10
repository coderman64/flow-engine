"""
controls the current ring count indicator
"""

extends Control


## the current number of collected rings
export var ringCount = 0

# stores references to each display digit
var digits = []

func _ready():
	# locate all the digits from smallest place to largest
	for i in range(3,0,-1):
		digits.append(get_node("Numbers/Digit %d/TextureRect2" % i))

func _process(_delta):
	# place stores the place multiplier for the value 
	var place = 1
	for i in digits:
		# get the current value (0-9) of the current digit
		var value = (ringCount/place) % 10
		
		# update the place multiplier
		place *= 10
		
		# change the display to reflect the given value
		i.rect_position.x = -24*value

func addRing():
	"""add a single ring to the ring count"""
	ringCount += 1
