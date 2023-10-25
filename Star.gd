extends RigidBody2D

@onready var pickup: Pickup = %Pickup

var SPEED = 75
var UP_SPEED = 250
var direction = Vector2(1.0, 1.0)
var velocity = Vector2(0.0, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pickup.type = "star"
	pickup.pickup_area.body_entered.connect(_on_pickup.bind(pickup.type))

func _physics_process(delta):
	velocity.x = SPEED * delta * direction.x
	velocity.y = UP_SPEED * delta * direction.y
	var collision_info = move_and_collide(velocity)
	if collision_info != null:
		direction = direction.bounce(collision_info.get_normal())

## callback for when the area2D is entered by a body
func _on_pickup(body: Node2D, type: String):
	if body is Player:
		body.item_pickup(type)
		self.queue_free()
