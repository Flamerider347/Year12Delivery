extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$floor.show()

func _on_chopping_board_area_entered(area: Area3D) -> void:
	if area.is_in_group("choppable"):
		area.add_to_group("can_chop")
