extends Node3D
var bun_chopped_top = preload("res://prefabs/bun_top_chopped.tscn")
var bun_chopped_bottom = preload("res://prefabs/bun_bottom_top.tscn")
var cheese_chopped = preload("res://prefabs/cheese_chopped.tscn")
var ingredients = {
"cheese": cheese_chopped
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$floor.show()


func _on_chopping_board_body_entered(body: Node3D) -> void:
	if body.is_in_group("choppable"):
		body.add_to_group("can_chop")


func _on_cut_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("can_chop"):
		if body.name == "bun":
			var instance = bun_chopped_bottom.instantiate()
			var instance2 = bun_chopped_top.instantiate()
			add_child(instance)
			add_child(instance2)
			instance.position = body.position
			instance2.position = body.position + Vector3(0,0.1,0)
			body.queue_free()
		else:
			var instance = ingredients[body.name].instantiate()
			instance.position = body.position
			add_child(instance)
			body.queue_free()
