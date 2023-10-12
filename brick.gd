class_name Brick extends Node2D

@onready var brick_area: Area2D = $BrickArea2D

func brick_break(breakable: bool):
	if breakable:
		print_debug("break")
	else:
		print_debug("bounce")
	
	for body in brick_area.get_overlapping_bodies():
		if body is Enemy:
			body.run_damage(false)
