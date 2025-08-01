extends Node3D
signal make_order
var controllers = 0
var sens_multiplyer = 50
var grid_exists = true
var player_exists = true
var bun_chopped_top = preload("res://prefabs/bun_top_chopped.tscn")
var bun_chopped_bottom = preload("res://prefabs/bun_bottom_chopped.tscn")
var making_time_left = 0
var next_spawn_time = 50
var order = false
var action
var objective_toggle = true
var orders = [0,0,0,0,0,0,0,0,0,0]
var objectives = {}
var product = []
var current_map
var player_count = 1
var level = 1
var level_updates_left = 0
var money = 100
var score = 0
var stars = 5
var orders_delivered = 0
var day_timer = 20
var is_tutorial = false
var world_toggle = false
# Defines the animation player for when the player moves between menus.
@onready var animation: AnimationPlayer = $"transition animation/transition animation"

@onready var pot = preload("res://prefabs/delivery_pot.tscn")
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
	"dine_in" : $dine_in,
	"volcano" : $volcano,
	"underwater" : $underwater,
	"siberia" : $siberia,
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
var benches = {
	"bench_1" : ["bin",0,true],
	"bench_2" : ["bench",0,true],
	"bench_3" : ["chopping_board",0,true],
	"bench_4" : ["bun_crate",0,true],
	"bench_5" : ["fridge",0,true],
	"bench_6" : ["bench",0,true],
	"bench_7" : ["stove",270,true],
	"bench_8" : ["bench",90,false],
	"bench_9" : ["bench",270,false],
	"bench_10" : ["bench",90,false],
	"bench_11" : ["bench",270,false],
	"bench_12" : ["bench",90,false],
	"bench_13" : ["bench",270,false],
	"bench_14" : ["bench",90,false],
	"bench_15" : ["bench",270,false],
	"bench_16" : ["bench",90,false],
	"bench_17" : ["bench",180,false],
	"bench_18" : ["delivery_table",180,true],
	}
var tutorial_benches = {
	"bench_1" : ["bin",0,true],
	"bench_2" : ["bench",0,true],
	"bench_3" : ["chopping_board",0,true],
	"bench_4" : ["bun_crate",0,true],
	"bench_5" : ["fridge",0,true],
	"bench_6" : ["bench",0,false],
	"bench_7" : ["stove",270,true],
	"bench_8" : ["bun_crate",90,false],
	"bench_9" : ["bun_crate",270,false],
	"bench_10" : ["bench",90,false],
	"bench_11" : ["bench",270,false],
	"bench_12" : ["bench",90,false],
	"bench_13" : ["bench",270,false],
	"bench_14" : ["bench",90,false],
	"bench_15" : ["bench",270,false],
	"bench_16" : ["bench",90,false],
	"bench_17" : ["bench",180,false],
	"bench_18" : ["delivery_table",180,true],
}
var unlocked_levels = {
	"level_1" :true,
	"level_2" : false,
	"level_3" : false,
	"level_4" : false,
}
func _ready() -> void:
	$GridContainer.hide()
	$ui/Sprite2D.hide()
	$ui/Sprite2D2.hide()
func tutorial():
	world_toggle = true
	$tutorial.show()
	$ui.show()
	$player_single.position = Vector3(0,31.65,5.3)
	is_tutorial = true
	for i in get_children():
		if i is RigidBody3D:
			i.queue_free()
	for i in $tutorial.get_children():
		if not i.is_in_group("keep"):
			i.queue_free()
	if player_count == 1:
		$ui/Label.text = ""
		$ui/Label2.text = ""
		$ui/Label3.text = ""
		$ui/Sprite2D.show()
		$GridContainer.hide()
		$ui/Sprite2D.position.x = 960
	if player_count == 2:
		$GridContainer.show()
		$GridContainer/SubViewportContainer/SubViewport/player._setup()
		$GridContainer/SubViewportContainer2/SubViewport/player2._setup()
		$player_single.hide()
		$GridContainer/SubViewportContainer/SubViewport/player.show()
		$GridContainer/SubViewportContainer2/SubViewport/player2.show()
		$GridContainer/SubViewportContainer/SubViewport/player.position = Vector3(1,31,6)
		$GridContainer/SubViewportContainer2/SubViewport/player2.position = Vector3(-1,31,6)
		$ui/Sprite2D.show()
		$ui/Sprite2D2.show()
		$ui/Sprite2D.position.x = 480
		$ui/Sprite2D2.position.x = 1440
	for i in tutorial_benches:
		if tutorial_benches[i][2] == true:
			if i in bench_summoning.keys():
				if tutorial_benches[i][0] in bench_types:
					var summoned_bench = bench_types[tutorial_benches[i][0]].instantiate()
					$tutorial.add_child(summoned_bench)
					summoned_bench.position = bench_summoning[i][0]
					summoned_bench.rotation_degrees.y = bench_summoning[i][1]
	orders_delivered = 0
	score = 0
	stars = $menu/CanvasLayer/layout.stars_bought
	$tutorial/plates.start()
	$tutorial/plates.randomise_objective()
	sens_multiplyer = $menu/CanvasLayer/options/HSlider.value
	$kitchen/sign_out/Label3D.text =  "Look at me and hold LEFT CLICK to End the day (Day incomplete)"
	$player_single.SENSITIVITY = sens_multiplyer * 0.1

func _setup():
	world_toggle = true
	is_tutorial = false
	for i in get_children():
		if i.is_in_group("clear"):
			i.queue_free()
		if i is RigidBody3D:
			i.queue_free()
	for i in $kitchen.get_children():
		
		if not i.is_in_group("keep"):
			i.queue_free()
	$ui.show()
	$tutorial.hide()
	$day_timer.start()
	map_select()
	if player_count == 1:
		$player_single._setup()
		$player_single/head/player_camera.current = true
		$ui/Sprite2D.show()
		$ui/Sprite2D2.hide()
		$GridContainer.hide()
		$ui/Sprite2D.position.x = 960
		$player_single.show()
		$GridContainer/SubViewportContainer/SubViewport/player.controlling = false
		$GridContainer/SubViewportContainer2/SubViewport/player2.controlling = false
		$GridContainer/SubViewportContainer/SubViewport/player.hide()
		$GridContainer/SubViewportContainer2/SubViewport/player2.hide()
	if player_count == 2:
		$GridContainer.show()
		$GridContainer/SubViewportContainer/SubViewport/player._setup()
		$GridContainer/SubViewportContainer2/SubViewport/player2._setup()
		$player_single.hide()
		$GridContainer/SubViewportContainer/SubViewport/player.show()
		$GridContainer/SubViewportContainer2/SubViewport/player2.show()
		$ui/Sprite2D.show()
		$ui/Sprite2D2.show()
		$ui/Sprite2D.position.x = 480
		$ui/Sprite2D2.position.x = 1440
	$order_timer.start(0.1)
	for i in benches:
		if benches[i][2] == true:
			if i in bench_summoning.keys():
				if benches[i][0] in bench_types:
					var summoned_bench = bench_types[benches[i][0]].instantiate()
					$kitchen.add_child(summoned_bench)
					summoned_bench.position = bench_summoning[i][0]
					summoned_bench.rotation_degrees.y = bench_summoning[i][1]
	orders_delivered = 0
	score = 0
	stars = $menu/CanvasLayer/layout.stars_bought
	$ui/Label.text = "Score: " + str(score)
	$ui/Label2.text = "Stars: " + str(stars)
	sens_multiplyer = $menu/CanvasLayer/options/HSlider.value
	$kitchen/sign_out/Label3D.text =  "Look at me and hold LEFT CLICK
	 to End the day (Day incomplete)"
	$player_single.SENSITIVITY = sens_multiplyer * 0.1
	if level == 1:
		$kitchen/billboard/Label3D.text = "Todays weather:         Cloudy with a chance of meatballs

Neighbourhood level
Difficulty level: SAFE
Dangers & Modifications:
-Timers on food, more score means more money
-If a timer runs out, you lose a star
-Losing all 5 stars restarts level, no money is rewarded"
	if level == 2:
		$kitchen/billboard/Label3D.text = "Todays weather:         Cloudy with a chance of meatballs

Volcano level
Difficulty level: C
Dangers & Modifications:
-LAVA!!!
-Touching lava will make you bounce around
-Lava burns delivery pots (-10% of the score/bounce)"
	if level == 3:
		$kitchen/billboard/Label3D.text = "Todays weather:         Cloudy with a chance of meatballs

Underwater level
Difficulty level: B
Dangers:
-Shark can steal your ingredients if you aren't watching
-Pickup the ingredient the Shark is going for to scare him
-Nothing can stop the Shark
-Gravity is weird because underwater"
		$underwater/fish.run_away()

func _physics_process(_delta: float) -> void:
	if $day_timer.time_left >0:
		var time = $day_timer.time_left
		var hours = round(int(time)) / 30
		var minutes = round(int(time*2)) % 60
		$ui/Label3.text = str(11-hours).pad_zeros(2) + ":" + str(59-minutes).pad_zeros(2) + " PM"
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


func _on_cut_area_body_entered(body: Node3D) -> void:
	if $player_single.held_object and $player_single.held_object.type == "knife" or $GridContainer/SubViewportContainer/SubViewport/player.held_object and $GridContainer/SubViewportContainer/SubViewport/player.held_object.type == "knife" or $GridContainer/SubViewportContainer2/SubViewport/player2.held_object and $GridContainer/SubViewportContainer2/SubViewport/player2.held_object.type == "knife":
		if body.is_in_group("can_chop"):
			$"SFX/knife chopping".global_position = body.global_position
			$"SFX/knife chopping".play()
			if body.type == "bun":
				if is_tutorial:
					$tutorial/plates.cut_bun()
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
				if is_tutorial:
					if body.type == "tomato":
						$tutorial/plates.cut_tomato()
				var instance = ingredients[body.type].instantiate()
				instance.type = body.type + "_chopped"
				instance.position = body.position
				add_child(instance)
				body.queue_free()


func _on_objective_plate_objective(changed_objective,plate_name,timer,address,plate_timer_name) -> void:
	objectives[plate_timer_name] = [changed_objective,timer,address,plate_name]


func plate_check(contents,body,plate_pos,plate_rotation) -> void:
	if body.is_in_group("packageable"):
		product = contents
		var sorted_product = product.duplicate()
		sorted_product.sort()
		for objective in objectives:
			var sorted_objective = objectives[objective][0].duplicate()
			sorted_objective.sort()
			if sorted_product == sorted_objective:
				var plate_number = objectives[objective][3]
				var spawned_box = pot.instantiate()
				add_child(spawned_box)
				if is_tutorial:
					var timer = $tutorial/plates.find_child(objective.name).find_child("order_time").time_left
					spawned_box.time_left_timer.start(timer)
				else:
					var timer = $kitchen/plates.find_child(objective.name).find_child("order_time").time_left
					spawned_box.time_left_timer.start(timer)
				spawned_box.position = plate_pos
				spawned_box.rotation_degrees.y = plate_rotation
				spawned_box.timer_number = plate_number
				spawned_box.target_location = objectives[objective][2]
				spawned_box.find_child("Label3D").text = objectives[objective][2]
				emit_signal("make_order","kill",plate_number)
				orders[int(plate_number)-1] = 0
				objectives.erase(objective)
				$SFX/ding.play()
				body.queue_free()
				if is_tutorial:
					$tutorial/plates.delivered()
				break
			else:
				pass


func _on_incinerator_body_entered(body: Node3D) -> void:
	if body.is_in_group("pickupable") and not body.is_in_group("knife") and not body.is_in_group("keep"):
		body.queue_free()


func _on_house_item_entered(address,target_address,time_left,delivered_pot) -> void:
	if address == target_address:
		if not is_tutorial:
			making_time_left = round(time_left)
			score += making_time_left
			$ui/Label.text = "Score " + str(score)
			$SFX/delivered.play()
			delivered_pot.queue_free()
			orders_delivered += 1

		else:
			$tutorial/plates.delivered_to_house()
			delivered_pot.queue_free()
			$SFX/delivered.play()
			$tutorial/plates.randomise_objective()


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
		$menu.lose_screen()
		stars = 5


func _on_plates_objective_clear(timer_number) -> void:
	orders[int(timer_number)-1] = 0
	objectives.erase(str("plate_" + str(timer_number)))


func _on_order_timeout(_number) -> void:
	stars -= 1
	$ui/Label2.text = "stars: " + str(stars)
	if stars <= 0:
		$menu.lose_screen()


func map_select():
	for i in maps.keys():
		maps[i].hide()
	var map_keys = maps.keys()
	var random_map = map_keys[level]
	current_map = maps[random_map]
	current_map.show()
	$kitchen.position = current_map.position
	$kitchen.position.y = 0.099
	if player_count == 1 :
		$player_single.position = current_map.position + Vector3(0,1.15,3)
	if player_count == 2:
		$GridContainer/SubViewportContainer/SubViewport/player.position = current_map.position + Vector3(2,1.15,3)
		$GridContainer/SubViewportContainer2/SubViewport/player2.position = current_map.position + Vector3(0,1.15,3)


func _on_day_timer_timeout() -> void:
	if level < 4:
		unlocked_levels["level_"+str(level+1)] = true
		print(unlocked_levels)
	$kitchen/sign_out/Label3D.text =  "Look at me and hold LEFT CLICK to End the day (Day complete)"
	$ui/Label3.text = "OVERTIME"
	$day_timer.stop()
	$order_timer.stop()


func looking_recipe(looking_at_list):
	$ui/looking_recipe.show()
	$ui/looking_recipe.text = ""
	for i in looking_at_list:
		$ui/looking_recipe.text = $ui/looking_recipe.text + "\n" + str(i).replacen("_"," ") 


func _on_volcano_lava_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.bounce()
