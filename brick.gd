class_name Brick extends Node2D

@onready var brick_area: Area2D = $BrickArea2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var brick_pieces_scene: PackedScene 

## Breaks the brick and runs code to kill the enemy if they are in area when called
func brick_break(breakable: bool):
	if breakable:
		queue_free()
		if brick_pieces_scene:
			var new_item = brick_pieces_scene.instantiate()
			new_item.position = position - Vector2(0, 12)
			add_sibling.call_deferred(new_item)
		print_debug("break")
	else:
		animation_player.play("bounce")
	
	for body in brick_area.get_overlapping_bodies():
		if body is Enemy:
			body.run_damage(false)
