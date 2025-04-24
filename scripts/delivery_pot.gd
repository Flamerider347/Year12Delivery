extends RigidBody3D
var contents = []
var target_location
@onready var delivery_location_text = $Label3D


func _on_world_order_contents(product_contents,delivery_location) -> void:
	delivery_location_text.text = delivery_location
	target_location = delivery_location
	contents = product_contents
	for child in get_children():
		if child.is_in_group("lid"):
			child.show()


func _on_world_delivered_correctly() -> void:
	target_location = null
	for child in get_children():
		if child.is_in_group("lid"):
			child.hide()
	position = Vector3(-1.5,1.1,4)
