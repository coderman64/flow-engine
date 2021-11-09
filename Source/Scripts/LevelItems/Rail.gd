# the system for creating rails from curves in Godot

extends Path2D

# line holds a reference to the Line2D (line renderer) node
onready var rail_line = get_node ("Line2D")
# coll holds a reference to the collision polygon
onready var rail_collision = get_node ("Area2D/CollisionPolygon2D")

func _ready () -> void:
	helper_functions._whocares = $"Area2D".connect ("area_entered", self, "_on_Area2D_area_entered")
	# set the line points for rendering 
	rail_line.points = curve.get_baked_points ()

	# create a reversed curve slightly below the original
	var invCurve = curve.get_baked_points ()
	invCurve.invert ()
	for i in range (invCurve.size ()):
		invCurve.set (i, Vector2 (invCurve[i].x, invCurve[i].y+1))

	# construct a "full curve" collision polygon, which follows the curve,
	# and is 1 pixel in height. This is done by taking the points from the 
	# initial curve, and adding the points from the "inverted" curve
	var fullCurve = curve.get_baked_points ()
	fullCurve.append_array (invCurve)

	# set the collider to use the newly constructed polygon
	rail_collision.polygon = fullCurve
	return

func _on_Area2D_area_entered (area) -> void:
	# if the player collides with this rail, call "_on_Rail_area_entered" to let it
	# know it should be grinding now.
	if (area is game_space.player_class):
		area._on_Rail_area_entered (area, curve, global_position)
		area.rotation = 0.0
	return
