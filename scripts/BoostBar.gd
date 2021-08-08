"""
Used to control the boost bar UI
"""

extends Control

export(PackedScene) var barUnit

var barItems = []

export (float) var boostAmount = 20

export (bool) var infiniteBoost = false

var growMode = false

var visualBar = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(20):
		barItems.append(barUnit.instance())
		barItems[i].rect_position = Vector2(0,-14*i-16)
		add_child(barItems[i])


func _process(delta):
	if visualBar < boostAmount and visualBar <= 60:
		visualBar += 0.5;
		barItems[floor(fmod(visualBar-2,20))].rect_scale.x = 4
	else:
		visualBar = boostAmount
		
	if boostAmount > 60:
		boostAmount = 60
	if boostAmount < 0:
		boostAmount = 0
	
	if boostAmount < 60 and infiniteBoost:
		boostAmount = 60
		
	var index = 0
	for i in barItems:
		index+=1;
		var colorVal = floor(visualBar/20)+(1 if floor(fmod(visualBar,20)) > index else 0)
		i.get_node("TextureRect").rect_position.y = -24+8*colorVal
		i.rect_scale.x = lerp(i.rect_scale.x,2,0.2)

func changeBy(x):
	boostAmount += x
