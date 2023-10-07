class_name ItemBlock extends AnimatableBody2D

@export var item_pickup: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func player_collide():
	print_debug("spawn item")
