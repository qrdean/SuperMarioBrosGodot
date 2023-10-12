class_name DeathZone extends Area2D

func _ready():
	body_entered.connect(_body_entered)

func _body_entered(body: Node2D):
	if body is Player:
		# probably call kill player here actually
		body.global_position = body.starting_pos
	if body is Enemy:
		body.queue_free()
