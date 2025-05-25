extends Node3D
signal order_contents
signal delivered_correctly
signal make_order
var grid_exists = true
var player_exists = true
var bun_chopped_top = preload("res://prefabs/bun_top_chopped.tscn")
var bun_chopped_bottom = preload("res://prefabs/bun_bottom_chopped.tscn")
var cheese_chopped = preload("res://prefabs/cheese_chopped.tscn")
var meat_chopped = preload("res://prefabs/meat_chopped.tscn")
var tomato_chopped = preload("res://prefabs/tomato_chopped.tscn")
var lettuce_chopped = preload("res://prefabs/lettuce_chopped.tscn")
var carrot_chopped = preload("res://prefabs/carrot_chopped.tscn")
var meat_cooked_chopped = preload("res://prefabs/meat_cooked_chopped.tscn")
var product_check = false
var making_time_left = 0
var next_spawn_time = 30
var order = false
var loaded = true
var action
var stars = Global.stars
var money = Global.money
var orders = [0,0,0,0,0,0,0,0,0,0]
var objectives = {}
var product = []
var current_map
var bench_summoning = {
	"bench_1" : [Vector3(-5,0,0),0],
	"bench_2" : [Vector3(-3,0,0),0],
	"bench_3" : [Vector3(-1,0,0),0],
	"bench_4" : [Vector3(1,0,0),0],
	"bench_5" : [Vector3(3,0,0),0],
	"bench_6" : [Vector3(5,0,0),0],
	"bench_7" : [Vector3(-5,0,2),90],
	"bench_8" : [Vector3(5,0,2),270],
	"bench_9" : [Vector3(-5,0,4),90],
	"bench_10" : [Vector3(5,0,4),270],
	"bench_11" : [Vector3(-5,0,6),90],
	"bench_12" : [Vector3(5,0,6),270],
	"bench_13" : [Vector3(-5,0,8),90],
	"bench_14" : [Vector3(5,0,8),270],
	"bench_15" : [Vector3(-5,0,10),90],
	"bench_16" : [Vector3(5,0,10),270],
	"bench_17" : [Vector3(-3,0,10),180],
	"bench_18" : [Vector3(3,0,10),180],
}
@onready var bench_types = {
	"bench"  : preload("res://prefabs/bench.tscn"),
	"stove"  : preload("res://prefabs/stove.tscn"),
	"chopping_board" : preload("res://prefabs/chopping_board.tscn"),
	"fridge" : preload("res://prefabs/fridge.tscn"),
	"bun_crate" : preload("res://prefabs/bun_crate.tscn"),
	"bin"    : preload("res://prefabs/bin.tscn"),
}
@onready var maps = {
	"tutorial" : $dine_in,
	"volcano" : $volcano,
	"underwater" : $underwater,
	"siberia" : $siberia,
	"dine_in" : $dine_in

}
var ingredients = {
"cheese": cheese_chopped,
"meat":meat_chopped,
"tomato":tomato_chopped,
"carrot":carrot_chopped,
"lettuce":lettuce_chopped,
"meat_cooked_chopped" : meat_cooked_chopped,
}

func _ready() -> void:
	$player_single.position = Vector3(1.8,1.1,4.3)
	$ui/Label.text = "Money: " + str(money)
	$day_timer.start()
	map_select()
	if Global.player_count == 1:
		$GridContainer.queue_free()
		$ui/Sprite2D2.hide()
		$ui/Sprite2D.position.x = 960
	if Global.player_count == 2:
		$player_single.queue_free()
	$order_timer.start(0.1)
	for i in Global.benches:
		if Global.benches[i][2] == true:
			if i in bench_summoning.keys():
				if Global.benches[i][0] in bench_types:
					var summoned_bench = bench_types[Global.benches[i][0]].instantiate()
					$kitchen.add_child(summoned_bench)
					summoned_bench.position = bench_summoning[i][0]
					summoned_bench.rotation_degrees.y = bench_summoning[i][1]
func _physics_process(_delta: float) -> void:
	if $day_timer.time_left >0:
		var time = $day_timer.time_left
		var minutes = round(int(time)) / 60
		var seconds = int(time) % 60
		$ui/Label3.text = str(15-minutes).pad_zeros(2) + ":" + str(59-seconds).pad_zeros(2)
	if order:
		for i in range(len(orders)):
			if orders[i] == 0:
				orders[i] = 1
				order = false
				$order_timer.start(next_spawn_time)
				break
			else:
				pass
		var count = 0
		for i in range(9):
			count += 1
			if orders[i] == 1:
				emit_signal("make_order","make",count)
				orders[i] = 2
	if $knife.position.y < 0.2:
		$knife.position = Vector3(5.2,1.1,0.4)
	if product_check:
		for objective in objectives:
			if product == objectives[objective][0]:
				var plate_number = objectives[objective][3]
				product_check = false
				var timer = $kitchen/plates.find_child(objective.name).find_child("order_time").time_left
				order_contents.emit(product,objectives[objective][2],timer,plate_number)
				emit_signal("make_order","kill",plate_number)
				orders[int(plate_number)-1] = 0
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
		

func _on_player_money_change() -> void:
	$ui/Label.text = "Money: " + str(money)

func _on_incinerator_body_entered(body: Node3D) -> void:
	if body.is_in_group("pickupable") and not body.is_in_group("knife") and not body.is_in_group("keep"):
		body.queue_free()
	if body.is_in_group("knife"):
		body.position = Vector3(5.2,1.1,0.4)


func _on_house_item_entered(address,target_address,time_left) -> void:
	if address == target_address:
		making_time_left = round(time_left)
		money += making_time_left
		$ui/Label.text = "Money: " + str(money)
		delivered_correctly.emit()
		$delivery_pot.position = current_map.position + Vector3(3,1.2,10)

func _on_order_timer_timeout() -> void:
	for i in range(len(orders)):
		if orders[i] == 0:
			order = true
			break
		else:
			pass

func _on_objective_plate_timeout(timer_number) -> void:
	orders[int(timer_number)-1] = 0
	objectives.erase(str("plate_" + str(timer_number)))
	stars -= 1
	$ui/Label2.text = "stars: " + str(stars)
	if stars <= 0:
		Global.restart = true

func _on_order_timeout(_number) -> void:
	stars -= 1
	$ui/Label2.text = "stars: " + str(stars)
	if stars <= 0:
		Global.restart = true

func map_select():
	for i in maps.keys():
		maps[i].hide()
	var map_keys = maps.keys()
	var random_map = map_keys[Global.level-1]
	var old_map = map_keys[Global.level-2]
	current_map = maps[random_map]
	current_map.show()
	$delivery_pot.position = current_map.position + Vector3(3,1.2,10)
	$knife.position = current_map.position + Vector3(5.2,1.1,0.4)
	$knife2.position = current_map.position + Vector3(5.6,1.1,0.4)
	$kitchen.position = current_map.position + Vector3(0,0.1,0)
	if Global.player_count == 1 :
		if loaded:
			$player_single.position = current_map.position + $player_single.position
			#$delivery_pot.position = current_map.position + $delivery_pot.position
			loaded = false
		else:
			$player_single.position = current_map.position + $player_single.position - maps[old_map].position
			#$delivery_pot.position = current_map.position + $delivery_pot.position - maps[old_map].position
	if Global.player_count == 2:
		$GridContainer/SubViewportContainer/SubViewport/player.position = current_map.position + Vector3(2,1.15,3)
		$GridContainer/SubViewportContainer2/SubViewport/player2.position = current_map.position + Vector3(0,1.15,3)


func _on_day_timer_timeout() -> void:
	if Global.level < 5:
		Global.level_updates_left += 1
		get_tree().change_scene_to_file("res://prefabs/menu.tscn")
