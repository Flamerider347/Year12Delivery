extends Node3D
signal objective_timeout
signal objective
signal objective_clear
var delivery_list = ["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"]
var delivery_location
var ingredient_amount = 0
var timing = false
var next_position = 0.1
var making_plate = "plate_1"
var recipes_list = {
	"burger_ben" : [["plate","bun_bottom_chopped","meat_cooked","cheese_chopped","lettuce_chopped","bun_top_chopped"],true],
	"burger_aine" : [["plate","bun_bottom_chopped","meat_cooked","cheese_chopped","meat_cooked","bun_top_chopped"],true],
	"burger_hayden" : [["plate","bun_bottom_chopped","cheese_chopped","cheese_chopped","cheese_chopped","bun_top_chopped"],true],
	"burger_sullivan" : [["plate","bun_bottom_chopped","lettuce_chopped","tomato_chopped","cheese_chopped","carrot_chopped","bun_top_chopped",],false],
	"burger_test" :[["plate","bun_bottom_chopped","bun_top_chopped"],false],
	"stew" : [["bowl", "carrot_chopped", "meat_cooked_chopped", "potato_chopped"],false]
}
var plate_contents = {
	"plate_1" : [],
	"plate_2" : [],
	"plate_3" : [],
	"plate_4" : [],
	"plate_5" : [],
	"plate_6" : [],
	"plate_7" : [],
	"plate_8" : [],
	"plate_9" : [],
	"plate_10" : []
}
@onready var plates = {
	"plate_1" : $objective_plate1,
	"plate_2" : $objective_plate2,
	"plate_3" : $objective_plate3,
	"plate_4" : $objective_plate4,
	"plate_5" : $objective_plate5,
	"plate_6" : $objective_plate6,
	"plate_7" : $objective_plate7,
	"plate_8" : $objective_plate8,
	"plate_9" : $objective_plate9,
	"plate_10" : $objective_plate10
}
var ingredient_time = {
	"plate" : 5,
	"bowl" : 5,
	"tomato_chopped":10,
	"meat_cooked": 15,
	"cheese_chopped": 10,
	"carrot_chopped":10,
	"lettuce_chopped":10,
	"bun_bottom_chopped" : 10,
	"bun_top_chopped" : 10,
}
var ingredient_list = {
	"plate" : preload("res://prefabs/plate.tscn"),
	"bowl" : preload("res://prefabs/bowl.tscn"),
	"tomato_chopped":preload("res://prefabs/tomato_chopped.tscn"),
	"meat_cooked": preload("res://prefabs/meat_cooked.tscn"),
	"meat_cooked_chopped" : preload("res://prefabs/meat_cooked_chopped.tscn"),
	"cheese_chopped": preload("res://prefabs/cheese_chopped.tscn"),
	"carrot_chopped":preload("res://prefabs/carrot_chopped.tscn"),
	"lettuce_chopped":preload("res://prefabs/lettuce_chopped.tscn"),
	"bun_bottom_chopped" : preload("res://prefabs/bun_bottom_chopped.tscn"),
	"bun_top_chopped" : preload("res://prefabs/bun_top_chopped.tscn"),
	"stew" : preload("res://prefabs/stew.tscn")
}
func _ready() -> void:
	$"../..".connect("make_order", Callable(self, "_on_make_order"))
func _process(_delta: float) -> void:
	for i in plates:
		var plate_label = plates[i].find_child("Label3D")
		var timer = plates[i].find_child("order_time")
		if timer.is_inside_tree() and timer.time_left > 10:
			plate_label.text = str(round(timer.time_left)).replace(".0","")
			plate_label.modulate = Color(1, 1, 1)
		elif timer.is_inside_tree() and timer.time_left > 0:
			plate_label.text = str(round(timer.time_left*10)/10)
			plate_label.modulate = Color(1, 0, 0)
		elif plate_label.text != "":
			plate_label.text = ""
func randomise_objective():
	var recipes_list_keys = recipes_list.keys()
	var making_recipe = recipes_list_keys[randi_range(0,recipes_list_keys.size()-1)]
	while recipes_list[making_recipe][1] == false:
		making_recipe = recipes_list_keys[randi_range(0,recipes_list_keys.size()-1)]
	var make_time = 200
	delivery_location = delivery_list[randi_range(0,8)]
	plate_contents[making_plate] = recipes_list[making_recipe][0].duplicate()
	for i in plate_contents[making_plate]:
		if i in ingredient_time.keys():
			make_time += ingredient_time[i]
	var plate_name = making_plate.replace("plate_", "")
	plates[making_plate].find_child("order_time").start(make_time)
	objective.emit(plate_contents[making_plate],plate_name,plates[making_plate].find_child("order_time").time_left,delivery_location,plates[making_plate])
	timing = true
	update_target(making_recipe.substr(0,6))
func update_target(recipe):
	var recipes_list_keys = recipes_list.keys()
	if recipe != "burger":
		plate_contents[making_plate] = ["stew",]
	next_position = 0.1
	for i in plate_contents[making_plate]:
		var spawned_item = ingredient_list[i].instantiate()
		var spawned_item_hitbox = spawned_item.find_child("CollisionShape3D").shape
		if plate_contents[making_plate].size() > 1:
			spawned_item.type = i
		plates[making_plate].add_child(spawned_item)
		spawned_item.remove_from_group("pickupable")
		spawned_item.freeze = true
		spawned_item.position = Vector3(0,next_position,0)
		if plate_contents[making_plate][0] in recipes_list_keys:
			plate_contents[making_plate] = recipes_list[plate_contents[making_plate][0]][0]
		if spawned_item_hitbox is BoxShape3D:
			var item_size = spawned_item_hitbox.size.y
			next_position += item_size
		elif spawned_item_hitbox is CylinderShape3D:
			var item_size = spawned_item_hitbox.height
			next_position += item_size
		if recipe != "burger":
			spawned_item.rotation_degrees.x = 50
			spawned_item.position = Vector3(0,0.4,-0.25)
		else:
			spawned_item.rotation_degrees.x = 0

func _on_make_order(action: String,plate_number) -> void:
	making_plate = str("plate_" + str(plate_number))
	if action == "kill":
		for child in plates[making_plate].get_children():
			if not child.is_in_group("keep"):
				child.queue_free()
		plate_contents[making_plate] = []
		var plate = plates[making_plate]
		plate.find_child("Label3D").text = ""
		plate.find_child("order_time").stop()
	elif action == "make":
		randomise_objective()

func _on_order_timeout(number) -> void:
	var plate = "plate_" + str(number)
	for child in plates[plate].get_children():
		if not child.is_in_group("keep"):
			child.queue_free()
	objective_timeout.emit(number)
	plate_contents[plate] = []
	plates[plate].find_child("Label3D").text = ""
	plates[plate].find_child("order_time").stop()


func clear():
	for i in range(10):
		i = i+1
		var plate = "plate_" + str(i)
		for child in plates[plate].get_children():
			if not child.is_in_group("keep"):
				child.queue_free()
		objective_clear.emit(i)
		plate_contents[plate].clear()
		plates[plate].find_child("Label3D").text = ""
		plates[plate].find_child("order_time").stop()
