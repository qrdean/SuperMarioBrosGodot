extends Node2D

@onready var piece1 = $Piece1
@onready var piece2 = $Piece2
@onready var piece3 = $Piece3
@onready var piece4 = $Piece4

@onready var break_block_sound: AudioStreamPlayer = $break_block

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var positionA = Vector2(-7.0, -7.0)
var positionB = Vector2(7.0, -7.0)
var positionC = Vector2(-7.0, 7.0)
var positionD = Vector2(7.0, 7.0)

var t = 0.0
var duration = 1.75

func _ready():
	break_block_sound.play()

func _process(delta):
	t += duration * delta
	piece1.position = piece1.position.lerp(positionA, min(t, 1.0))
	piece2.position = piece2.position.lerp(positionB, min(t, 1.0))
	piece3.position = piece3.position.lerp(positionC, min(t, 1.0))
	piece4.position = piece4.position.lerp(positionD, min(t, 1.0))

	if piece1.position == positionA:
		self.queue_free()
