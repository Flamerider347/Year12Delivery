extends Node3D
signal correct_order
var bun_chopped_top = preload("res://prefabs/bun_top_chopped.tscn")
var bun_chopped_bottom = preload("res://prefabs/bun_bottom_chopped.tscn")
var cheese_chopped = preload("res://prefabs/cheese_chopped.tscn")
var meat_chopped = preload("res://prefabs/meat_chopped.tscn")
var tomato_chopped = preload("res://prefabs/tomato_chopped.tscn")
var lettuce_chopped = preload("res://prefabs/lettuce_chopped.tscn")
var carrot_chopped = preload("res://prefabs/carrot_chopped.tscn")
var product_check = false
var objective = []
var product = []
var ingredients = {
"cheese": cheese_chopped,
"meat":meat_chopped,
"tomato":tomato_chopped,
"carrot":carrot_chopped,
"lettuce":lettuce_chopped,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$floor.show()
	$fridge_door.rotation_degrees.y = -90

func _physics_process(_delta: float) -> void:
	if $knife.position.y < 0.2:
		$knife.position = Vector3(5.2,1.1,0.4)
	if product_check:
		if product == objective:
			product_check = false
			$player.money += 10 
			correct_order.emit()
			var random_success = randi_range(1,4)
			if random_success == 1:
				$beautiful.play()
			if random_success == 2:
				$yippie.play()
			if random_success == 3:
				$well_done.play()
			if random_success == 4:
				$homer_mmmm.play()
		else:
			product_check = false
func _on_chopping_board_body_entered(body: Node3D) -> void:
	if body.is_in_group("choppable"):
		body.add_to_group("can_chop")

func _on_chopping_board_body_exited(body: Node3D) -> void:
	if body.is_in_group("choppable"):
		body.remove_from_group("can_chop")
		
func _on_cut_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("can_chop"):
		if body.type == "bun":
			var instance = bun_chopped_bottom.instantiate()
			var instance2 = bun_chopped_top.instantiate()
			add_child(instance)
			add_child(instance2)
			instance.type = "bun_bottom_chopped"
			instance2.type = "bun_top_chopped"
			instance.position = body.position
			instance2.position = body.position + Vector3(0,0.1,0)
			body.queue_free()
		elif body.type in ingredients:
			if body.is_in_group("meat"):
				var instance = ingredients[body.type].instantiate()
				instance.position = body.position
				add_child(instance)
			else:
				var instance = ingredients[body.type].instantiate()
				instance.type = body.type + "_chopped"
				instance.position = body.position
				add_child(instance)
			body.queue_free()
		else:
			pass


func _on_objective_plate_objective(changed_objective) -> void:
	objective = changed_objective


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("stackable"):
		product = body.contents
		product_check = true
		body.queue_free()
		


func _on_player_money_change(money) -> void:
	$ui/Label.text = "Money: " + str(money)


func _on_correct_order() -> void:
	$ui/Label.text = "Money: " + str($player.money)


func _on_stove_body_entered(body: Node3D) -> void:
	if body.is_in_group("cookable"):
		body.cooking = true


func _on_stove_body_exited(body: Node3D) -> void:
	if body.is_in_group("cookable"):
		body.cooking = false
		$counter/stove/stove_timer.text = ""

func _on_incinerator_body_entered(body: Node3D) -> void:
	if body.is_in_group("pickupable") and not body.is_in_group("knife"):
		body.queue_free()
	if body.is_in_group("knife"):
		body.position = Vector3(5.2,1.1,0.4)


func _on_refresh_timer_timeout() -> void:
	if $counter/stove/stove_timer.rotation_degrees.y != $player/head.rotation_degrees.y:
		$counter/stove/stove_timer.rotation_degrees.y = $player/head.rotation_degrees.y
	if $objective_plate/objective_timer.rotation_degrees.y != $player/head.rotation_degrees.y:
		$objective_plate/objective_timer.rotation_degrees.y = $player/head.rotation_degrees.y
