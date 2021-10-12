# flips the player between two available collision layers

extends Area2D

export(String, "layer 0", "layer 1", "toggle") var function = "layer 0"

func _ready () -> void:
	helper_functions._whocares = self.connect ("area_entered", self, "_on_LayerSwitch_area_entered")
	return

func _on_LayerSwitch_area_entered (area) -> void:
	if (area is game_space.player_class):
		match (function):	# Switch layers.
			"layer 0":
				area._layer0 (area)
			"layer 1":
				area._layer1 (area)
			"toggle":
				area._flipLayer (area)
	return
