extends Area3D
signal item_entered


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("deliverable"):
		item_entered.emit(self.name,body.target_location)
