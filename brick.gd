class_name Brick extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func player_collide(breakable: bool):
	if breakable:
		print_debug("break")
	else:
		print_debug("bounce")
