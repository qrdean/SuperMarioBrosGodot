extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var state = NORMAL
var prev_state = NORMAL

enum {
	NORMAL,
	SUPER,
	FIREFLOWER,
	STARPOWER
}

@onready var star_timer = $star_timer
@onready var head_area = $head

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	star_timer.wait_time = 7.0
	star_timer.one_shot = true
	star_timer.timeout.connect(_on_star_timeout)
	head_area.body_entered.connect(_on_head_body_entered)

func _physics_process(delta):
	# for i in get_slide_collision_count():
	# 	var collision = get_slide_collision(i)
	# 	print_debug(collision.get_collider().name)

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


	move_and_slide()

func _on_head_body_entered(body: Node2D):
	if body is Brick:
		if state == NORMAL:
			body.player_collide(false)
		else:
			body.player_collide(true)
	
	if body is ItemBlock:
		body.player_collide()


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
	if(state == NORMAL):
		# make super mario
		state = SUPER
	else:
		# extra life
		print_debug("give 1 up")

func handle_fire_flower():
	if(state != FIREFLOWER):
		state = FIREFLOWER
	else:
		# store the fireflower up top
		print_debug("store flower")

func handle_star():
	if(state != STARPOWER):
		prev_state = state
		state = STARPOWER
		star_timer.start()
	else:
		# store the star??
		print_debug("store star")

func _on_star_timeout():
	print_debug("star timed out")
	self.state = prev_state
	print_debug(state)

