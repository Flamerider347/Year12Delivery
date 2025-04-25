extends Node3D
signal correct_order
signal order_contents
signal delivered_correctly
signal make_order_1
signal make_order_2
signal make_order_3
signal make_order_4
signal make_order_5
signal make_order_6
signal make_order_7
signal make_order_8
signal make_order_9
var bun_chopped_top = preload("res://prefabs/bun_top_chopped.tscn")
var bun_chopped_bottom = preload("res://prefabs/bun_bottom_chopped.tscn")
var cheese_chopped = preload("res://prefabs/cheese_chopped.tscn")
var meat_chopped = preload("res://prefabs/meat_chopped.tscn")
var tomato_chopped = preload("res://prefabs/tomato_chopped.tscn")
var lettuce_chopped = preload("res://prefabs/lettuce_chopped.tscn")
var carrot_chopped = preload("res://prefabs/carrot_chopped.tscn")
var product_check = false
var making_time_left = 0
var next_spawn_time = 30
var order = false
var action
var stars = 5
var orders = [0,0,0,0,0,0,0,0,0]
var objectives = {}
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
	$order_timer.start(0.1)
	$floor.show()
	$fridge_door.rotation_degrees.y = -90

func _physics_process(_delta: float) -> void:
	if order:
		for i in range(len(orders)):
			if orders[i] == 0:
				orders[i] = 1
				order = false
				break
			else:
				pass
#region demonic variables
	if orders[0] == 1:
		action = "make"
		make_order_1.emit(action)
		orders[0]= 2
	if orders[1] == 1:
		action = "make"
		make_order_2.emit(action)
		orders[1]= 2
	if orders[2] == 1:
		action = "make"
		make_order_3.emit(action)
		orders[2]= 2
	if orders[3] == 1:
		action = "make"
		make_order_4.emit(action)
		orders[3]= 2
	if orders[4] == 1:
		action = "make"
		make_order_5.emit(action)
		orders[4]= 2
	if orders[5] == 1:
		action = "make"
		make_order_6.emit(action)
		orders[5]= 2
	if orders[6] == 1:
		action = "make"
		make_order_7.emit(action)
		orders[6]= 2
	if orders[7] == 1:
		action = "make"
		make_order_8.emit(action)
		orders[7]= 2
	if orders[8] == 1:
		action = "make"
		make_order_9.emit(action)
		orders[8]= 2
	if orders[0] == 3:
		action = "kill"
		make_order_1.emit(action)
		orders[0]= 0
	if orders[1] == 3:
		action = "kill"
		make_order_2.emit(action)
		orders[1]= 0
	if orders[2] == 3:
		action = "kill"
		make_order_3.emit(action)
		orders[2]= 0
	if orders[3] == 3:
		action = "kill"
		make_order_4.emit(action)
		orders[3]= 0
	if orders[4] == 3:
		action = "kill"
		make_order_5.emit(action)
		orders[4]= 0
	if orders[5] == 3:
		action = "kill"
		make_order_6.emit(action)
		orders[5]= 0
	if orders[6] == 3:
		action = "kill"
		make_order_7.emit(action)
		orders[6]= 0
	if orders[7] == 3:
		action = "kill"
		make_order_8.emit(action)
		orders[7]= 0
	if orders[8] == 3:
		action = "kill"
		make_order_9.emit(action)
		orders[8]= 0
#endregion
	if $knife.position.y < 0.2:
		$knife.position = Vector3(5.2,1.1,0.4)
	if product_check:
		for objective in objectives:
			if product == objectives[objective][0]:
				var plate_number = objectives[objective][3]
				orders[int(plate_number)-1] = 3
				product_check = false
				var timer = find_child(objective).find_child("order_time").time_left
				order_contents.emit(product,objectives[objective][2],timer)
				objectives.erase(objective)
				var random_success = randi_range(1,4)
				if random_success == 1:
					$beautiful.play()
				if random_success == 2:
					$yippie.play()
				if random_success == 3:
					$well_done.play()
				if random_success == 4:
					$homer_mmmm.play()
				break
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


func _on_objective_plate_objective(changed_objective,plate_name,timer,address,plate_timer_name) -> void:
	objectives[plate_timer_name] = [changed_objective,timer,address,plate_name]


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("stackable"):
		product = body.contents
		product_check = true
		body.queue_free()
		


func _on_player_money_change(money) -> void:
	$ui/Label.text = "Money: " + str(money)


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
func _on_house_item_entered(address,target_address,time_left) -> void:
	if address == target_address:
		making_time_left = round(time_left)
		$player.money += making_time_left
		$player.money_change.emit($player.money)
		delivered_correctly.emit()
		correct_order.emit()
		$professional_timer.start()


func _on_order_timer_timeout() -> void:
	for i in range(len(orders)):
		if orders[i] == 0:
			order = true
			break
		else:
			pass
	$order_timer.start(next_spawn_time)
	next_spawn_time = 30



func _on_objective_plate_timeout() -> void:
	stars -= 1
	$ui/Label2.text = "stars: " + str(stars)
	if stars <= 0:
		get_tree().change_scene_to_file("res://prefabs/menu.tscn")


func _on_delivery_pot_timeout() -> void:
	stars -= 1
	$ui/Label2.text = "stars: " + str(stars)
	if stars <= 0:
		get_tree().change_scene_to_file("res://prefabs/menu.tscn")


func _on_professional_timer_timeout() -> void:
	for i in range(len(orders)):
		print(orders)
		var completed_plates = 9
		if orders[i] == 0:
			completed_plates -=1
			order = true
		else:
			break
		if completed_plates == 0:
			print("time_let = 30")
			$order_timer.time_left = 30
