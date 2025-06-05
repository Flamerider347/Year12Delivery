extends Node3D
signal order_contents
signal delivered_correctly
signal make_order
var grid_exists = true
var player_exists = true
var bun_chopped_top = preload("res://prefabs/bun_top_chopped.tscn")
var bun_chopped_bottom = preload("res://prefabs/bun_bottom_chopped.tscn")
var product_check = false
var making_time_left = 0
var next_spawn_time = 1
var order = false
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
	"delivery_table" : preload("res://prefabs/delivery_table.tscn")
}
@onready var maps = {
	"tutorial" : $dine_in,
	"volcano" : $volcano,
	"underwater" : $underwater,
	"siberia" : $siberia,
	"dine_in" : $dine_in

}
var ingredients = {
"potato": preload("res://prefabs/potato_chopped.tscn"),
"cheese": preload("res://prefabs/cheese_chopped.tscn"),
"meat":preload("res://prefabs/meat_chopped.tscn"),
"tomato":preload("res://prefabs/tomato_chopped.tscn"),
"carrot":preload("res://prefabs/carrot_chopped.tscn"),
"lettuce":preload("res://prefabs/lettuce_chopped.tscn"),
"meat_cooked" : preload("res://prefabs/meat_cooked_chopped.tscn"),
}

func _ready() -> void:
	$GridContainer.hide()
	$ui/Sprite2D.hide()
	$ui/Sprite2D2.hide()
	$knife.freeze = true
	$knife2.freeze = true
func _setup():
	for i in $kitchen.get_children():
		if not i.is_in_group("keep"):
			i.queue_free()
	$ui.show()
	$ui/Label.text = "Money: " + str(money)
	$day_timer.start()
	map_select()
	if Global.player_count == 1:
		$ui/Sprite2D.show()
		$GridContainer.hide()
		$ui/Sprite2D.position.x = 960
	if Global.player_count == 2:
		$GridContainer.show()
		$ui/Sprite2D.show()
		$ui/Sprite2D2.show()
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
		for i in range(10):
			count += 1
			if orders[i] == 1:
				emit_signal("make_order","make",count)
				orders[i] = 2
	if $knife.position.y < 0.2:
		$knife.position.y += 1.1
	if $knife2.position.y < 0.2:
		$knife2.position.y += 1.1

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
			var instance = ingredients[body.type].instantiate()
			instance.type = body.type + "_chopped"
			instance.position = body.position
			add_child(instance)
			body.queue_free()


func _on_objective_plate_objective(changed_objective,plate_name,timer,address,plate_timer_name) -> void:
	objectives[plate_timer_name] = [changed_objective,timer,address,plate_name]

func plate_check(contents,body) -> void:
	if body.is_in_group("packageable"):
		product = contents
		var sorted_product = product.duplicate()
		sorted_product.sort()
		for objective in objectives:
			var sorted_objective = objectives[objective][0].duplicate()
			sorted_objective.sort()
			if sorted_product == sorted_objective:
				var plate_number = objectives[objective][3]
				product_check = false
				var timer = $kitchen/plates.find_child(objective.name).find_child("order_time").time_left
				order_contents.emit(product,objectives[objective][2],timer,plate_number)
				emit_signal("make_order","kill",plate_number)
				orders[int(plate_number)-1] = 0
				objectives.erase(objective)
				var random_success = randi_range(1,4)
				if random_success == 1:
					$SFX/beautiful.play()
				if random_success == 2:
					$SFX/yippie.play()
				if random_success == 3:
					$SFX/well_done.play()
				if random_success == 4:
					$SFX/homer_mmmm.play()
				body.queue_free()
				break
			else:
				print("failed")


func _on_player_money_change() -> void:
	$ui/Label.text = "Money: " + str(money)

func _on_incinerator_body_entered(body: Node3D) -> void:
	if body.is_in_group("pickupable") and not body.is_in_group("knife") and not body.is_in_group("keep"):
		body.queue_free()



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
		$menu.menu_load()
		stars = 5

func _on_plates_objective_clear(timer_number) -> void:
	orders[int(timer_number)-1] = 0
	objectives.erase(str("plate_" + str(timer_number)))

func _on_order_timeout(_number) -> void:
	stars -= 1
	$ui/Label2.text = "stars: " + str(stars)
	if stars <= 0:
		Global.restart = true
		$menu.menu_load()

func map_select():
	for i in maps.keys():
		maps[i].hide()
	var map_keys = maps.keys()
	var random_map = map_keys[Global.level-1]
	current_map = maps[random_map]
	current_map.show()
	$knife.freeze = false
	$knife2.freeze = false
	$knife.position = current_map.position + Vector3($knife.position.x,1.1,$knife.position.z)
	$knife2.position = current_map.position + Vector3($knife2.position.x,1.1,$knife2.position.z)
	$delivery_pot.position = current_map.position + Vector3(3,1.1,10)
	$kitchen.position = current_map.position
	if Global.player_count == 1 :
		$player_single.position = current_map.position + Vector3(0,1.15,3)
	if Global.player_count == 2:
		$GridContainer/SubViewportContainer/SubViewport/player.position = current_map.position + Vector3(2,1.15,3)
		$GridContainer/SubViewportContainer2/SubViewport/player2.position = current_map.position + Vector3(0,1.15,3)


func _on_day_timer_timeout() -> void:
	if Global.level < 5:
		Global.level_updates_left += 1
		$menu.menu_load()

func looking_recipe(looking_at_list):
	if looking_at_list.size() == 1 and looking_at_list[0] in Global.recipes_list.keys():
		looking_at_list = Global.recipes_list[looking_at_list[0]][0]
	$ui/looking_recipe.show()
	$ui/looking_recipe.text = ""
	for i in looking_at_list:
		$ui/looking_recipe.text = $ui/looking_recipe.text + "\n" + str(i).replacen("_"," ") 
