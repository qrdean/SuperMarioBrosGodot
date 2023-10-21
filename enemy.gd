class_name Enemy extends CharacterBody2D


const SPEED = 30.0
var direction: float = -1.0

var killed = false

@export var enemy_type: String

@onready var hurtbox: Area2D = %hurtbox
@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var mock_animation_timer: Timer = %mock_animation_timer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	animation_sprite.animation_finished.connect(_run_animation_finished)
	# mock_animation_timer.timeout.connect(_run_mock_animation_timer)
	hurtbox.area_entered.connect(_on_hurtbox_entered)
	# TODO: would want to make an initialization layer to handle different enemies
	# But for this small project is simple
	if enemy_type == "goomba":
		animation_sprite.play("goomba_walk")
	elif enemy_type == "turtle":
		print_debug("play turtle walk")

func _physics_process(delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision && collision.get_collider():
			if collision.get_collider() is Enemy:
				direction = -direction
			elif collision.get_collider() is TileMap && is_on_wall():
				direction = -direction

	if killed:
		direction = 0.0

	if not is_on_floor():
		velocity.y += gravity * delta
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

## when the player runs into the enemy trigger this
func _on_hurtbox_entered(area: Node2D):
	if area.get_parent() != null:
		if area.get_parent() is Player:
			var player_character = area.get_parent()
			player_character.damage_player(self)
			print_debug("on player")

## There is different Animations between these two. Could set a flag or something for
## One function that gets passed in. Instead of this
func run_damage(stomp: bool):
	hurtbox.monitoring = false
	killed = true
	if stomp:
		animation_sprite.play("goomba_dead")
	else:
		animation_sprite.play("goomba_dead")
		print_debug("play other animation")
	# mock_animation_timer.start()

# TODO: replace me once animations are in place
func _run_mock_animation_timer():
	self.queue_free()

func _run_animation_finished():
	if animation_sprite.animation == "goomba_dead":
		self.queue_free()

