class_name Fireflower extends Node2D

@onready var pickup: Pickup = %Pickup

# Called when the node enters the scene tree for the first time.
func _ready():
	pickup.type = "fireflower"
	pickup.score = 1000
	pickup.pickup_area.body_entered.connect(_on_pickup)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_pickup(body: Node2D):
	if body is Player:
		body.item_pickup(pickup.type, pickup.score)
		self.queue_free()

