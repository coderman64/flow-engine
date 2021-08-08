"""
flips sonic between the two available collision layers
"""

extends Area2D


export(String, 'layer 0', 'layer 1', 'toggle') var function = 'layer 0'

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _tripped(area):
	if area.name == 'Player':
		if function == 'layer 0':
			area._layer0(area)
		if function == 'layer 1':
			area._layer1(area)
		if function == 'toggle':
			area._flipLayer(area)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
