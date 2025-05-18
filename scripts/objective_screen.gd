extends Node3D
signal objective_timeout
signal objective
var delivery_list = ["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"]
var delivery_location
var ingredient_amount = 0
var timing = false
var next_position = 0.1
var making_plate = "plate_1"
var recipes_list = Global.recipes_list
var ingredients = {
	"ingredient_1" : "bun_bottom_chopped",
	"ingredient_2" : null,
	"ingredient_3" : null,
	"ingredient_4" : null,
	"ingredient_5" : null,
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
	"tomato_chopped":10,
	"meat_cooked": 15,
	"cheese_chopped": 10,
	"carrot_chopped":10,
	"lettuce_chopped":10,
	"bun_bottom_chopped" : 10,
	"bun_top_chopped" : 10,
}
var burger_list = {
	"tomato_chopped":preload("res://prefabs/tomato_chopped.tscn"),
	"meat_cooked": preload("res://prefabs/meat_cooked.tscn"),
	"cheese_chopped": preload("res://prefabs/cheese_chopped.tscn"),
	"carrot_chopped":preload("res://prefabs/carrot_chopped.tscn"),
	"lettuce_chopped":preload("res://prefabs/lettuce_chopped.tscn"),
	"bun_bottom_chopped" : preload("res://prefabs/bun_bottom_chopped.tscn"),
	"bun_top_chopped" : preload("res://prefabs/bun_top_chopped.tscn"),
}
func _ready() -> void:
	$"../..".connect("make_order", Callable(self, "_on_make_order"))
func _process(_delta: float) -> void:
	for i in plates:
		var plate_label = plates[i].find_child("Label3D")
		var timer = plates[i].find_child("order_time")
		if timer.is_inside_tree() and timer.time_left > 0:
			plate_label.text = str(round(timer.time_left*10)/10)
		elif plate_label.text != "":
			plate_label.text = ""
func randomise_objective():
	delivery_location = delivery_list[randi_range(0,8)]
	var list_keys = burger_list.keys()
	var list_size = list_keys.size()
	ingredient_amount = randi_range(2,4)
	plate_contents[making_plate].append("bun_bottom_chopped")
	for i in ingredient_amount:
		if i !=0:
			if ingredient_amount - i > 0:
				ingredients["ingredient_" + str(i)] = list_keys[randi_range(0, list_size - 3)]
				plate_contents[making_plate].append(ingredients["ingredient_"+str(i)])
			if ingredient_amount - i == 1:
				ingredients["ingredient_" + str(i)] = "bun_top_chopped"
				plate_contents[making_plate].append(ingredients["ingredient_"+str(i)])
	var plate_name = making_plate.replace("plate_", "")
	var make_time = -10
	for i in ingredients:
		if ingredients[i]:
			make_time += ingredient_time[ingredients[i]]
	plates[making_plate].find_child("order_time").start(make_time)
	objective.emit(plate_contents[making_plate],plate_name,plates[making_plate].find_child("order_time").time_left,delivery_location,plates[making_plate])
	timing = true
	update_target()
func update_target():
	next_position = 0.1
	for i in plate_contents[making_plate]:
			var spawned_item = burger_list[i].instantiate()
			var spawned_item_hitbox = spawned_item.find_child("CollisionShape3D").shape
			plates[making_plate].add_child(spawned_item)
			spawned_item.remove_from_group("pickupable")
			spawned_item.freeze = true
			spawned_item.position = Vector3(0,next_position,0)
			if spawned_item_hitbox is BoxShape3D:
				var item_size = spawned_item_hitbox.size.y
				next_position += item_size
			elif spawned_item_hitbox is CylinderShape3D:
				var item_size = spawned_item_hitbox.height
				next_position += item_size

func _on_make_order(action: String,plate_number) -> void:
	making_plate = str("plate_" + str(plate_number))
	if action == "kill":
		for child in plates[making_plate].get_children():
			if not child.is_in_group("keep"):
				child.queue_free()
		ingredient_amount = 0
		next_position = 0.1
		plate_contents[making_plate] = []
		var plate = plates[making_plate]
		plate.find_child("Label3D").text = "0"
		plate.find_child("order_time").stop()
	elif action == "make":
		randomise_objective()

func _on_order_timeout(number) -> void:
	var plate = "plate_" + str(number)
	for child in plates[plate].get_children():
		if not child.is_in_group("keep"):
			child.queue_free()
	for i in ingredients:
		ingredients[i] = null
	ingredient_amount = 0
	next_position = 0.1
	objective_timeout.emit(number)
	plate_contents[plate].clear()
	plates[plate].find_child("Label3D").text = "0"
	plates[plate].find_child("order_time").stop()
