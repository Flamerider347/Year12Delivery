extends RigidBody3D
var contents = []
var target_location
signal timeout
@onready var delivery_location_text = $Label3D
@onready var time_left_text = $Label3D2
@onready var time_left_timer = $Timer


func _on_world_order_contents(product_contents,delivery_location,time_left) -> void:
	add_to_group("pickupable")
	delivery_location_text.text = delivery_location
	time_left_timer.start(time_left)
	target_location = delivery_location
	contents = product_contents
	for child in get_children():
		if child.is_in_group("lid"):
			child.show()
func _physics_process(_delta: float) -> void:
	time_left_text.text = str(round(time_left_timer.time_left))

func _on_world_delivered_correctly() -> void:
	remove_from_group("pickupable")
	time_left_timer.stop()
	target_location = null
	for child in get_children():
		if child.is_in_group("lid"):
			child.hide()
	position = Vector3(-1.5,1.1,4)


func _on_timer_timeout() -> void:
	remove_from_group("pickupable")
	time_left_timer.stop()
	target_location = null
	for child in get_children():
		if child.is_in_group("lid"):
			child.hide()
	position = Vector3(-1.5,1.1,4)
	timeout.emit()
