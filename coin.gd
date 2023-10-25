extends Node2D
class_name Coin

@onready var pickup: Pickup = %Pickup
@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pickup.type = "coin"
	pickup.score = 200
	pickup.pickup_area.body_entered.connect(_on_pickup)
	animation_sprite.play("coin_anim")
	
func _on_pickup(body: Node2D):
	if body is Player:
		body.item_pickup(pickup.type, pickup.score)
		self.queue_free()
