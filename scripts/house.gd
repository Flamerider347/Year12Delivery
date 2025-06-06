extends Area3D
signal item_entered

func _ready() -> void:
	$house.find_child("Label3D").text = "House " + str(self.name)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("deliverable"):
		var time_left = body.time_left_timer.time_left
		item_entered.emit(self.name,body.target_location,time_left,body)
