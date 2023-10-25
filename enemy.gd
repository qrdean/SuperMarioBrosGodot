class_name Enemy extends CharacterBody2D


const SPEED = 30.0
var direction: float = -1.0

var killed = false
var wait = true

@export var enemy_type: String

@onready var hurtbox: Area2D = %hurtbox
@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Super hacky. Don't love this method of getting a static node for distance 
# checking maybe a hieger level function sending signal down?
@onready var player = get_node("../Player")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	print_debug(player)
	animation_sprite.animation_finished.connect(_run_animation_finished)
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
	
	if self.global_position.distance_to(player.global_position) < 300.0 and wait:
		wait = false

	if not wait:
		move_and_slide()

## when the player runs into the enemy trigger this
func _on_hurtbox_entered(area: Node2D):
	if !killed:
		if area.get_parent() != null:
			if area.get_parent() is Player:
				var player_character = area.get_parent()
				player_character.damage_player(self)
				print_debug("on player")

## There is different Animations between these two. Could set a flag or something for
## One function that gets passed in. Instead of this
func run_damage(stomp: bool):
	# hurtbox.monitoring = false
	killed = true
	hurtbox.call_deferred("set_monitoring", false)
	if stomp:
		animation_sprite.play("goomba_dead")
	else:
		animation_sprite.flip_v = true
		animation_sprite.play("goomba_dead")
		print_debug("play other animation")

func _run_animation_finished():
	if animation_sprite.animation == "goomba_dead":
		self.queue_free()

