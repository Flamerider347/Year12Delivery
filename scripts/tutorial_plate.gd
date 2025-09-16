extends Node3D
signal objective_timeout
signal objective
signal objective_clear
var delivery_location
var ingredient_amount = 0
var timing = false
var step = 0
var next_position = 0.1
var making_plate = "plate_1"
var recipes_list = {
	"burger_test" :[["plate","bun_bottom_chopped","tomato_chopped","bun_top_chopped"],true],
}
var plate_contents = {
	"plate_1" : [],
}
@onready var plates = {
	"plate_1" : $objective_plate1,
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
	var make_time = 120
	delivery_location = "A1"
	plate_contents[making_plate] = recipes_list[making_recipe][0].duplicate()
	make_time = 999
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
			plate_contents[making_plate] = recipes_list[plate_contents[making_plate][0]][0].duplicate()
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
	plate_contents[plate].clear()
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

func start():
	$"../tutorial_text".position = Vector3(-0.5,2.0,0)
	$"../tutorial_text".rotation_degrees = Vector3.ZERO
	$"../tutorial_text".text = "Let's play a game, come a
 little closer with Left Joystick
			"
func _on_area_3d_body_entered(body: Node3D) -> void:
	if step == 0:
		if body is CharacterBody3D:
			$"../tutorial_text".text = "If you're ever unsure what to do, 
			try press 'T' to toggle bench tips
			on or off in any level.
			"
			$"../tutorial_text".position = Vector3(-0.5,2.0,0)
			$"../tutorial_text".rotation_degrees = Vector3.ZERO
			step = 1
func toggle_tips(): 
	if step == 1:
		$"../tutorial_text".text = "Get a PLATE from the PANTRY to your right
		 Holding L2 and put it on the BENCH
			"
		$"../tutorial_text".position = Vector3(-0.5,2.0,0)
		$"../tutorial_text".rotation_degrees = Vector3.ZERO
		step = 2
func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if step == 2:
		if body is RigidBody3D:
			if body.type == "plate":
				$"../tutorial_text".text = "Great, now get a bun and put it on the chopping board.
				If you don't know what you're making,
				it tells you when you look up at it.
				(On the right side of screen.)
				"
				step = 3


func _on_area_3d_3_body_entered(body: Node3D) -> void:
	if step == 3:
		if body is RigidBody3D:
			if body.type == "bun":
				$"../tutorial_text".text = "Great, now pick up the KNIFE
				"
				step = 4
	
func pickup_knife():
	if step == 4:
		$"../tutorial_text".text = "Great, now SWING the KNIFE into the BUN to cut it
			"
		step = 5
func cut_bun():
	if step == 5:
		$"../tutorial_text".text = "Now open the fridge using L2, and chop up a TOMATO.
				"
		step = 6
func cut_tomato():
	if step == 6:
		$"../tutorial_text".text = "Pick up the BOTTOM BUN and assemble the 
		BURGER on the PLATE using R2.
		Your crosshair will change to arrows
		when you can stack something.
				"
		step = 7

func complete_burger():
	if step == 7:
		$"../tutorial_text".text = "
		Put the completed burger 
		on the plate behind you for inspection.
		You must match the ORDER exactly, 
		but the ingredient order is irrelevant.
				"
		step = 8
func delivered():
	if step == 8:
		$"../tutorial_text".position = Vector3(2.7,2.3,10.9)
		$"../tutorial_text".rotation_degrees.y = 180
		$"../tutorial_text".text = "Now pickup the BAG using L2
		and deliver it to the HOUSE stated 
		on the DELIVERY BAG by dropping
		it on the DOORSTEP in time.
				"
		step = 9
func delivered_to_house():
	if step == 9:
		$"../tutorial_text".text = "You Beat the tutorial!
		Press to leave or redo the tutorial
		by walking back to the starting bench. 
		Good luck, have fun!
			"
		step = 0
