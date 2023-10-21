extends RigidBody2D
class_name Fireball

@export var SPEED = 200

@onready var fireball_collision: CollisionShape2D = %fireball_shape
@onready var fireball_hitbox: Area2D = %hitbox
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

## need to set x direction based on player facing 
var direction: Vector2 = Vector2(1.0, 1.0) 
var initial_x_direction: float

func _ready():
	initial_x_direction = direction.x
	fireball_hitbox.body_entered.connect(_fireball_area_body_entered)
	animation.play("fireball")

func _physics_process(_delta):
	var velocity = SPEED * _delta * direction
	var collision_info = move_and_collide(velocity)
	if collision_info:
		if collision_info != null:
			direction = direction.bounce(collision_info.get_normal())
			if direction.x == -initial_x_direction:
				self.queue_free()

func _fireball_area_body_entered(body):
	if body is Enemy:
		body.run_damage(false)
		self.queue_free()
	print_debug(body)
