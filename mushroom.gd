extends RigidBody2D
class_name Mushroom

@export var SPEED = 50

@onready var pickup: Pickup = %Pickup

var direction = Vector2(1.0, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pickup.type = "mushroom"
	pickup.pickup_area.body_entered.connect(_on_pickup.bind(pickup.type))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(delta):
	var velocity = SPEED * delta * direction
	var collision_info = move_and_collide(velocity)
	if collision_info != null:
		direction.x = direction.bounce(collision_info.get_normal()).x

## callback for when the area2D is entered by a body
func _on_pickup(body: Node2D, type: String):
	if body is Player:
		body.item_pickup(type)
		self.queue_free()
