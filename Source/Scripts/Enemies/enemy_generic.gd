### enemy_generic.gd
# Generic script for all enemies. Contains the variables and any functions that all enemies rely upon.

extends Area2D

export(PackedScene) var boostParticle

# How many hits does the enemy have left before being destroyed?
export(int) var hits_left = 1

# How much is this enemy worth in points?
export(int) var points_value = 100

# keeps track of the pawn's velocity once it has "exploded"
var explode_velocity := Vector2.ZERO

func _ready () -> void:
	# The function that this refers to should be created in the actual scripts for enemies.
	helper_functions._whocares = self.connect ("area_entered", self, "_on_enemy_area_entered")
	return
