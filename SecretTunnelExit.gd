extends Area2D
class_name SecretTunnelExit

@onready var camera_2d = %Camera2D

var exiting = false
# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Player):
	body.global_position = $TargetLocation2.global_position
	camera_2d.position.y = $TargetCameraLocation2.global_position.y

