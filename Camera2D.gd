class_name Camera extends Camera2D

@export var node_to_follow: Node2D

func _physics_process(_delta):
	position = lerp(position, node_to_follow.position, 0.60)
