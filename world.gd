extends Node2D
class_name World

@onready var overworld_music = $Overworld
@onready var starmode_music = $Starmode
@onready var lose_life_music = $LoseLife

@onready var player: Player = $Player

var starmode_flag = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player.star_mode_enable.connect(_star_mode_enable)
	player.star_mode_disable.connect(_star_mode_disable)
	player.lose_life.connect(_lose_life)
	lose_life_music.finished.connect(_reset_after_music)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _lose_life():
	overworld_music.stop()
	lose_life_music.play()
	lose_life_music.play()

func _star_mode_enable():
	overworld_music.stop()
	starmode_music.play()
	starmode_music.finished.connect(_loop_starmode)

func _loop_starmode():
	starmode_music.play()

func _star_mode_disable():
	starmode_music.finished.disconnect(_loop_starmode)
	starmode_music.stop()
	overworld_music.play()

func _reset_after_music():
	get_tree().reload_current_scene()
