class_name ItemBlock extends AnimatableBody2D

var has_item = true

@export var item_pickup: PackedScene

func item_block_collision():
	if has_item:
		has_item = false
		var new_item = item_pickup.instantiate()
		add_sibling.call_deferred(new_item)
		new_item.visible = true
		new_item.position = position - Vector2(0, 20)

