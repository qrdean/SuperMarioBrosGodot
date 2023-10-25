extends Area2D
class_name SecretTunnel

@onready var tunnel_timer = %secret_tunnel_timer
@onready var target_location = %TargetLocation
@onready var target_camera_location = %TargetCameraLocation
@onready var camera_2d = %Camera2D

var entering = false
# Called when the node enters the scene tree for the first time.
func _ready():
	tunnel_timer.wait_time = 1.0
	tunnel_timer.one_shot = true
	tunnel_timer.timeout.connect(_on_tunnel_timeout)

	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exit)

func _on_body_entered(body: Node2D):
	if body is Player:
		print_debug(camera_2d)
		body.enter_tunnel_attempt.connect(_enter_tunnel.bind(body))
		print_debug("player connect signal")

func _on_body_exit(body: Node2D):
	if body is Player:
		body.enter_tunnel_attempt.disconnect(_enter_tunnel)
		print_debug("player disconnect signal")

func _enter_tunnel(player: Player):
	if !entering:
		entering = true
		player.global_position = target_location.global_position
		camera_2d.position.y = target_camera_location.global_position.y
		tunnel_timer.start()

func _on_tunnel_timeout():
	entering = false
