extends Node3D
signal objective_timeout
signal objective
var delivery_list = ["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C2", "C3"]
var delivery_location
var ingredient_amount = 0
var timing = false
var ingredient_1 = null
var ingredient_2 = null
var ingredient_3 = null
var ingredient_4 = null
var ingredient_5 = null
var next_position = 0.1
var making_plate = "plate_1"
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
}
@onready var plate_timers = {
	"plate_1" : $objective_plate1/order_time,
	"plate_2" : $objective_plate2/order_time,
	"plate_3" : $objective_plate3/order_time,
	"plate_4" : $objective_plate4/order_time,
	"plate_5" : $objective_plate5/order_time,
	"plate_6" : $objective_plate6/order_time,
	"plate_7" : $objective_plate7/order_time,
	"plate_8" : $objective_plate8/order_time,
	"plate_9" : $objective_plate9/order_time,
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
var ingredient_list = {
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
func _physics_process(_delta: float) -> void:
	for i in plates:
		var plate_label = plates[i].find_child("Label3D")
		var timer = plates[i].find_child("order_time")
		if timer.is_inside_tree():
			plate_label.text = str(round(timer.time_left))
		else:
			plate_label.text = "0"

func randomise_objective():
	delivery_location = delivery_list[randi_range(0,8)]
	var list_keys = ingredient_list.keys()
	var list_size = list_keys.size()
	ingredient_amount = randi_range(3, 5)

	if ingredient_amount > 1:
		ingredient_1 = "bun_bottom_chopped"
		plate_contents[making_plate].append(ingredient_1)
	if ingredient_amount > 2:
		ingredient_2 = list_keys[randi_range(0, list_size - 3)]
		plate_contents[making_plate].append(ingredient_2)
	if ingredient_amount == 2:
		ingredient_2 = "bun_top_chopped"
		ingredient_3 = null
		ingredient_4 = null
		ingredient_5 = null
		plate_contents[making_plate].append(ingredient_2)
	if ingredient_amount > 3:
		ingredient_3 = list_keys[randi_range(0, list_size - 3)]
		plate_contents[making_plate].append(ingredient_3)
	if ingredient_amount == 3:
		ingredient_3 = "bun_top_chopped"
		ingredient_4 = null
		ingredient_5 = null
		plate_contents[making_plate].append(ingredient_3)
	if ingredient_amount > 4:
		ingredient_4 = list_keys[randi_range(0, list_size - 3)]
		plate_contents[making_plate].append(ingredient_4)
	if ingredient_amount == 4:
		ingredient_4 = "bun_top_chopped"
		ingredient_5 = null
		plate_contents[making_plate].append(ingredient_4)
	if ingredient_amount == 5:
		ingredient_5 = "bun_top_chopped"
		plate_contents[making_plate].append(ingredient_5)
	var plate_name = making_plate.replace("plate_", "")
	var make_time = -20
	make_time += ingredient_time[ingredient_1]
	make_time += ingredient_time[ingredient_2]
	make_time += ingredient_time[ingredient_3]
	if ingredient_4:
		make_time += ingredient_time[ingredient_1]
		if ingredient_5:
			make_time += ingredient_time[ingredient_1]
	plate_timers[making_plate].start(make_time)
	objective.emit(plate_contents[making_plate],plate_name,plate_timers[making_plate].time_left,delivery_location,plates[making_plate])
	timing = true
	update_target()
func update_target():
	var item_1 = ingredient_list[ingredient_1].instantiate()
	var item_hitbox_1 = item_1.find_child("CollisionShape3D").shape
	var item_2 = ingredient_list[ingredient_2].instantiate()
	var item_hitbox_2 = item_2.find_child("CollisionShape3D").shape
	plates[making_plate].add_child(item_1)
	item_1.remove_from_group("pickupable")
	item_1.freeze = true
	item_1.position = Vector3(0,next_position,0)
	if item_hitbox_1 is BoxShape3D:
		var item_size = item_hitbox_1.size.y
		next_position += item_size
	elif item_hitbox_1 is CylinderShape3D:
		var item_size = item_hitbox_1.height
		next_position += item_size
		
	plates[making_plate].add_child(item_2)
	item_2.remove_from_group("pickupable")
	item_2.freeze = true
	item_2.position = Vector3(0,next_position,0)
	if item_hitbox_2 is BoxShape3D:
		var item_size = item_hitbox_2.size.y
		next_position += item_size
	elif item_hitbox_2 is CylinderShape3D:
		var item_size = item_hitbox_2.height
		next_position += item_size

	if ingredient_3:
		var item_3 = ingredient_list[ingredient_3].instantiate()
		var item_hitbox_3 = item_3.find_child("CollisionShape3D").shape
		plates[making_plate].add_child(item_3)
		item_3.remove_from_group("pickupable")
		item_3.freeze = true
		item_3.position = Vector3(0,next_position,0)
		if item_hitbox_3 is BoxShape3D:
			var item_size = item_hitbox_3.size.y
			next_position += item_size
		elif item_hitbox_3 is CylinderShape3D:
			var item_size = item_hitbox_3.height
			next_position += item_size
	if ingredient_4:
		var item_4 = ingredient_list[ingredient_4].instantiate()
		var item_hitbox_4 = item_4.find_child("CollisionShape3D").shape
		plates[making_plate].add_child(item_4)
		item_4.remove_from_group("pickupable")
		item_4.freeze = true
		item_4.position = Vector3(0,next_position,0)
		if item_hitbox_4 is BoxShape3D:
			var item_size = item_hitbox_4.size.y
			next_position += item_size
		elif item_hitbox_4 is CylinderShape3D:
			var item_size = item_hitbox_4.height
			next_position += item_size
	if ingredient_5:
		var item_5 = ingredient_list[ingredient_5].instantiate()
		plates[making_plate].add_child(item_5)
		item_5.freeze = true
		item_5.remove_from_group("pickupable")
		item_5.position = Vector3(0,next_position,0)
	next_position = 0.1

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

func _on_delivery_pot_timeout(number) -> void:
	var plate = "plate_" + str(number)
	for child in plates[plate].get_children():
		if not child.is_in_group("keep"):
			child.queue_free()
	ingredient_amount = 0
	next_position = 0.1
	objective_timeout.emit(number)
	plate_contents[plate].clear()
	plates[plate].find_child("Label3D").text = "0"
	plates[plate].find_child("order_time").stop()

func _on_objective_plate_timed_out_timer(number) -> void:
	var plate = "plate_" + str(number)
	for child in plates[plate].get_children():
		if not child.is_in_group("keep"):
			child.queue_free()
	ingredient_amount = 0
	next_position = 0.1
	objective_timeout.emit(number)
	plate_contents[plate].clear()
	plates[plate].find_child("Label3D").text = "0"
	plates[plate].find_child("order_time").stop()
