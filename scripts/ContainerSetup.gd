# UNUSED

extends Viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Node2D/Player/Camera2D").zoom = Vector2(1,1)
	get_node("Node2D").remove_child(get_node("Node2D/CanvasLayer"))
