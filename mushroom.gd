extends Node2D
class_name Mushroom

@onready var pickup: Pickup = %Pickup

# Called when the node enters the scene tree for the first time.
func _ready():
	pickup.type = "mushroom"
	pickup.pickup_area.body_entered.connect(_on_pickup.bind(pickup.type))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

## callback for when the area2D is entered by a body
func _on_pickup(body: Node2D, type: String):
	if body is Player:
		body.item_pickup(type)
		self.queue_free()
