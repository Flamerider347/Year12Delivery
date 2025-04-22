extends Node3D
var bun_chopped_top = preload("res://prefabs/bun_top_chopped.tscn")
var bun_chopped_bottom = preload("res://prefabs/bun_bottom_chopped.tscn")
var cheese_chopped = preload("res://prefabs/cheese_chopped.tscn")
var product_check = false
var objective = []
var product = []
var ingredients = {
"cheese": cheese_chopped
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$floor.show()

func _physics_process(_delta: float) -> void:
	if product_check:
		if product == objective:
			print("good job")
			product_check = false
		else:
			print("you suck")
			product_check = false
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
		elif body.name in ingredients:
			var instance = ingredients[body.name].instantiate()
			instance.position = body.position
			add_child(instance)
			body.queue_free()
		else:
			pass


func _on_objective_plate_objective(changed_objective) -> void:
	objective = changed_objective
	print("objective", objective)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("stackable"):
		product = body.contents
		print("product", product)
		product_check = true
		


func _on_player_money_change(money) -> void:
	$ui/Label.text = "Money: " + str(money)
