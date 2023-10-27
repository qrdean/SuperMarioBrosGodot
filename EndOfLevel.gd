extends Area2D
class_name EndOfLevel

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var camera_2d := %Camera2D
@onready var player_sprite := %player_sprite
@onready var overworld_music = $"../Overworld"
@onready var star_mode_music = $"../Starmode"
signal end_of_level
# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Player):
	overworld_music.stop()
	star_mode_music.stop()
	end_of_level.emit()
	body.visible = false
	if body.state == Player.MarioState.NORMAL:
		player_sprite.play("s_ride")
	elif body.state == Player.MarioState.SUPER:
		player_sprite.play("ride")
	elif body.state == Player.MarioState.FIREFLOWER:
		player_sprite.play("f_ride")
	camera_2d.node_to_follow = player_sprite 
	# body.queue_free()
	animation_player.play("level_finished")
