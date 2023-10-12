extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var state = MarioState.NORMAL
var prev_state = MarioState.NORMAL

# TODO: should remove this
var starting_pos: Vector2

enum MarioState {
	NORMAL,
	SUPER,
	FIREFLOWER,
	STARPOWER
}

@onready var star_timer = $star_timer
@onready var head_area = %head
@onready var hurtbox_area = %hurtbox
@onready var hitbox_area = %hitbox

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	starting_pos = global_position

	star_timer.wait_time = 7.0
	star_timer.one_shot = true
	star_timer.timeout.connect(_on_star_timeout)

	head_area.body_entered.connect(_on_head_body_entered)

	hitbox_area.monitoring = false
	hitbox_area.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision && collision.get_collider():
			if collision.get_collider() is Enemy && hitbox_area.monitoring:
				velocity.y = JUMP_VELOCITY

	if not is_on_floor():
		velocity.y += gravity * delta
		hitbox_area.monitoring = true
	elif hitbox_area.monitoring:
		hitbox_area.monitoring = false

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

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
	if state == MarioState.NORMAL:
		print_debug("player killed")
	elif state == MarioState.SUPER:
		state = MarioState.NORMAL
		print_debug(state)
	elif state == MarioState.FIREFLOWER:
		state = MarioState.SUPER
		print_debug(state)
	elif state == MarioState.STARPOWER:
		# kill enemy
		# probably should separate out the states to their own hit/hurtboxes?
		# realistically starpower should mean we are hurting enemies not them 
		# "damage"ing us and us reflecting
		enemy.run_damage(false)

#### ITEM HANDLING ###

## Item pick up script. This could be handled by resource files or something
## but a string will work for this small project
func item_pickup(type: String):
	if type == "mushroom":
		print_debug("pickedup mushroom")
		handle_mushroom()
		print_debug(state)
	elif type == "fireflower":
		print_debug("pickedup flower")
		handle_fire_flower()
		print_debug(state)
	elif type == "star":
		print_debug("pickedup star")
		handle_star()
		print_debug(state)
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
	print_debug("star timed out")
	self.state = prev_state
	print_debug(state)

