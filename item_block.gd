class_name ItemBlock extends AnimatableBody2D

var has_item = true

@export var item_pickup: PackedScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	animated_sprite.play("idle")

## Handles item_block_collision with the player
func item_block_collision():
	animated_sprite.play("spent")
	if has_item:
		has_item = false
		if (item_pickup):
			var new_item = item_pickup.instantiate()
			add_sibling.call_deferred(new_item)
			new_item.visible = true
			new_item.position = position - Vector2(0, 12)

