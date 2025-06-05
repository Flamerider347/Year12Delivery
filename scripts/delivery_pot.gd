extends RigidBody3D
var contents = []
var target_location
var timer_number
var type = "delivery_pot"
signal timeout
@onready var delivery_location_text = $Label3D
@onready var time_left_text = $Label3D2
@onready var time_left_timer = $Timer

func _physics_process(_delta: float) -> void:
	time_left_text.text = str(round(time_left_timer.time_left))

func _on_world_delivered_correctly() -> void:
	remove_from_group("pickupable")
	time_left_timer.stop()
	target_location = null
	for child in get_children():
		if child.is_in_group("lid"):
			child.hide()
	queue_free()


func _on_timer_timeout() -> void:
	remove_from_group("pickupable")
	time_left_timer.stop()
	target_location = null
	for child in get_children():
		if child.is_in_group("lid"):
			child.hide()
	timeout.emit(timer_number)
	queue_free()
