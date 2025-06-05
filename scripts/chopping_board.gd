extends StaticBody3D
@onready var knife = $knife
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	knife.reparent($"../..")
func _on_chopping_board_body_entered(body: Node3D) -> void:
	if body.is_in_group("choppable"):
		body.add_to_group("can_chop")

func _on_chopping_board_body_exited(body: Node3D) -> void:
	if body.is_in_group("choppable"):
		body.remove_from_group("can_chop")
