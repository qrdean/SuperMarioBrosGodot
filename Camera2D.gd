class_name Camera extends Camera2D

@export var node_to_follow: Node2D

## Put Camera movement in Phsyics Process Always!!!
func _physics_process(_delta):
	position.x = lerp(position, node_to_follow.position, 0.60).x
	# position = lerp(position, node_to_follow.position, 0.60)
