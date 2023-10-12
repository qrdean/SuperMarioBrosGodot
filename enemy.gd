class_name Enemy extends CharacterBody2D


const SPEED = 30.0
var direction: float = -1.0

var killed = false

@onready var hurtbox: Area2D = %hurtbox
@onready var mock_animation_timer: Timer = %mock_animation_timer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	mock_animation_timer.timeout.connect(_run_mock_animation_timer)
	hurtbox.area_entered.connect(_on_hurtbox_entered)

func _physics_process(delta):
	# TODO: Remove this is for debug
	direction = 0.0
	# Add the gravity.
	if killed:
		direction = 0.0

	if not is_on_floor():
		velocity.y += gravity * delta

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

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
		print_debug("play the animation")
	else:
		print_debug("play other animation")
	mock_animation_timer.start()

func _run_mock_animation_timer():
	self.queue_free()
