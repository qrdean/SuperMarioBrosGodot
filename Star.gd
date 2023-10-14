extends Node2D

@onready var pickup: Pickup = %Pickup

# Called when the node enters the scene tree for the first time.
func _ready():
	pickup.type = "star"
	pickup.pickup_area.body_entered.connect(_on_pickup.bind(pickup.type))

# TODO: move the star
func _process(_delta):
	pass

## callback for when the area2D is entered by a body
func _on_pickup(body: Node2D, type: String):
	if body is Player:
		body.item_pickup(type)
		self.queue_free()
