extends CharacterBody2D
class_name Player

const SPEED = 200.0
const JUMP_VELOCITY = -350.0
var state = MarioState.NORMAL : set = _set_state

func _set_state(new_state):
	state = new_state
	current_animation_dictionary = get_animation_dictionary()
	handle_collision_change()

var prev_state = MarioState.NORMAL

# TODO: should remove this
var starting_pos: Vector2

enum MarioState {
	NORMAL,
	SUPER,
	FIREFLOWER,
	STARPOWER
}

var jumping = false

@onready var star_timer: 	 Timer = $star_timer
@onready var invuln_timer: 	 Timer = $invuln_timer
@onready var head_area: 	 Area2D = %head
@onready var hurtbox_area: Area2D = %hurtbox
@onready var hitbox_area:  Area2D = %hitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var small_head_area: 	 Area2D = %small_head
@onready var small_hurtbox_area: Area2D = %small_hurtbox
@onready var small_hitbox_area:  Area2D = %small_hitbox
@onready var small_collision_shape: CollisionShape2D = %small_collision_shape
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D

@export var fireball_scene: PackedScene

var death = false
var invuln = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_animation_dictionary: Dictionary = {}

var dictionary_of_normal_animations: Dictionary = {"idle": "normal_idle", "run": "normal_run", "jump": "normal_jump"}
var dictionary_of_super_animations: Dictionary = {"idle": "super_idle", "run": "super_run", "jump": "super_jump"}
var dictionary_of_fireflower_animations: Dictionary = {"idle": "fire_idle", "run": "fire_run", "jump": "fire_jump"}
# var dictionary_of_star_animations: Dictionary = {"idle": "normal_idle", "run": "normal_run", "jump": "normal_jump"}

signal enter_tunnel_attempt

func _ready():
	starting_pos = global_position
	current_animation_dictionary = get_animation_dictionary()
	animation_player.play(current_animation_dictionary.get("idle"))

	star_timer.wait_time = 7.0
	star_timer.one_shot = true
	star_timer.timeout.connect(_on_star_timeout)

	invuln_timer.wait_time = .75
	invuln_timer.one_shot = true
	invuln_timer.timeout.connect(_on_invuln_timeout)

	collision_shape.disabled = true
	head_area.monitoring = false
	head_area.body_entered.connect(_on_head_body_entered)
	small_head_area.body_entered.connect(_on_head_body_entered)

	hitbox_area.monitoring = false
	hitbox_area.area_entered.connect(_on_hitbox_area_entered)
	small_hitbox_area.monitoring = false
	small_hitbox_area.area_entered.connect(_on_hitbox_area_entered)
	death = false
	handle_collision_change()

func _physics_process(delta):
	if !death:
		handle_enemy_jump_collisions()
		handle_jump(delta)
		handle_input()
		handle_movement_animations()
	else:
		handle_physics_death(delta)
	move_and_slide()

#### physics process functions ####
func handle_physics_death(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_input():
	if Input.is_action_just_pressed("fireball") && state == MarioState.FIREFLOWER:
		_launch_fireball()
	
	if Input.is_action_pressed("down"):
		enter_tunnel_attempt.emit()

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
func handle_movement_animations():
	if velocity.x > 0 && !jumping:
		animation_player.play(current_animation_dictionary.get("run"))
		animation_player.flip_h = false
	elif velocity.x < 0 && !jumping:
		animation_player.play(current_animation_dictionary.get("run"))
		animation_player.flip_h = true
	elif !jumping:
		animation_player.play(current_animation_dictionary.get("idle"))

func handle_jump(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		hitbox_area.monitoring = true
		jumping = true
	elif hitbox_area.monitoring:
		jumping = false
		hitbox_area.monitoring = false

	if jumping:
		animation_player.play(current_animation_dictionary.get("jump"))

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_enemy_jump_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision && collision.get_collider():
			if collision.get_collider() is Enemy && hitbox_area.monitoring:
				velocity.y = JUMP_VELOCITY

### Mario State Handling ###
func get_animation_dictionary():
	match state:
		MarioState.NORMAL:
			return dictionary_of_normal_animations 
		MarioState.SUPER:
			return dictionary_of_super_animations
		MarioState.FIREFLOWER:
			return dictionary_of_fireflower_animations
	# This will be fixed later
	return dictionary_of_super_animations	

func handle_collision_change():
	if death:
		small_collision_shape.call_deferred("set_disabled", true)
		small_head_area.monitoring = false
		small_hurtbox_area.monitoring = false
		head_area.monitoring = false
		hurtbox_area.monitoring = false
		$CollisionShape2D.call_deferred("set_disabled", true)
		return

	var small_mario: bool = state == MarioState.NORMAL
	print_debug("handling collision change")
	if small_mario:
		small_collision_shape.call_deferred("set_disabled", false)
		small_head_area.monitoring = true
		small_hurtbox_area.monitoring = true
		head_area.monitoring = false
		hurtbox_area.monitoring = false
		$CollisionShape2D.call_deferred("set_disabled", true)
		return

	# small_collision_shape.disabled 	= true
	small_collision_shape.call_deferred("set_disabled", true)
	small_head_area.monitoring 			= false
	small_hurtbox_area.monitoring 	= false
	head_area.monitoring 						= true
	hurtbox_area.monitoring 				= true
	$CollisionShape2D.call_deferred("set_disabled", false)


### Mario signal callbacks ###

## Callback when the head of mario enters a Node2D body
## Handles breaking of bricks and triggering item blocks
func _on_head_body_entered(body: Node2D):
	if body is Brick:
		if state == MarioState.NORMAL:
			body.brick_break(false)
		else:
			body.brick_break(true)
	
	if body is ItemBlock:
		body.item_block_collision()

## Callback when the foot of mario steps on a Node2D body
func _on_hitbox_area_entered(area: Node2D):
	if area.get_parent() != null:
		if area.get_parent() is Enemy:
			var enemy = area.get_parent()
			enemy.run_damage(true)

## External Callable Code

## Call to run damage on the player by this or another script
## If it is an enemy that calls this code pass it in as Mario could
## be in the Star State
func damage_player(enemy: Node2D):
	if invuln:
		return
	else:
		invuln = true
		invuln_timer.start()

	if state == MarioState.NORMAL:
		print_debug("player killed")
		_player_death()
	elif state == MarioState.SUPER:
		print_debug("mario to normal")
		state = MarioState.NORMAL
	elif state == MarioState.FIREFLOWER:
		print_debug("mario to normal")
		state = MarioState.SUPER
	elif state == MarioState.STARPOWER:
		# kill enemy
		# probably should separate out the states to their own hit/hurtboxes?
		# realistically starpower should mean we are hurting enemies not them 
		# "damage"ing us and us reflecting
		enemy.run_damage(false)

func _player_death():
	animation_player.play("death")
	death = true
	velocity = Vector2.ZERO
	handle_collision_change()
	velocity.y = JUMP_VELOCITY

#### ITEM HANDLING ###

## Item pick up script. This could be handled by resource files or something
## but a string will work for this small project
func item_pickup(type: String):
	if type == "mushroom":
		handle_mushroom()
	elif type == "fireflower":
		handle_fire_flower()
	elif type == "star":
		handle_star()
	elif type == "coin":
		print_debug("type coin. add to score")
	else:
		print_debug("type unknown")
		print_debug(type)

func handle_mushroom():
	if(state == MarioState.NORMAL):
		# make super mario
		state = MarioState.SUPER
	else:
		# extra life
		print_debug("give 1 up")

func handle_fire_flower():
	if(state != MarioState.FIREFLOWER):
		state = MarioState.FIREFLOWER
	else:
		# store the fireflower up top
		print_debug("store flower")

func handle_star():
	if(state != MarioState.STARPOWER):
		prev_state = state
		state = MarioState.STARPOWER
		star_timer.start()
	else:
		# store the star??
		print_debug("store star")

## Ends the star state by moving back the the previous state.
## would like to explore how to pass in a var here to handle prev_state, but when 
## we hook up the signal it holds on to the reference instead of letting us pass on start
func _on_star_timeout():
	self.state = prev_state

func _launch_fireball() -> void:
	var fireball: Fireball = fireball_scene.instantiate()
	fireball.global_position = get_global_position()
	if animation_player.flip_h:
		fireball.initial_x_direction = -1.0
	else:
		fireball.initial_x_direction = 1.0
	add_sibling(fireball)

func _on_invuln_timeout():
	invuln = false
