extends StaticBody3D

signal objective

var ingredient_amount = 0
var ingredient_1 = null
var ingredient_2 = null
var ingredient_3 = null
var ingredient_4 = null
var ingredient_5 = null
var next_position = 0.1
var contents = []
var ingredient_list = {
	"bun_bottom_chopped": preload("res://prefabs/bun_bottom_chopped.tscn"),
	"bun_top_chopped": preload("res://prefabs/bun_top_chopped.tscn"),
	"cheese_chopped": preload("res://prefabs/cheese_chopped.tscn"),
	"cheese": preload("res://prefabs/cheese.tscn")
}


func _ready() -> void:
	randomise_objective()

func randomise_objective():
	var list_keys = ingredient_list.keys()
	var list_size = list_keys.size()
	ingredient_amount = randi_range(2, 5)

	if ingredient_amount > 1:
		ingredient_1 = "bun_bottom_chopped"
		contents.append(ingredient_1)
	if ingredient_amount > 2:
		ingredient_2 = list_keys[randi_range(0, list_size - 1)]
		contents.append(ingredient_2)
	if ingredient_amount == 2:
		ingredient_2 = "bun_bottom_chopped"
		contents.append(ingredient_2)
	if ingredient_amount > 3:
		ingredient_3 = list_keys[randi_range(0, list_size - 1)]
		contents.append(ingredient_3)
	if ingredient_amount == 3:
		ingredient_3 = "bun_top_chopped"
		contents.append(ingredient_3)
	if ingredient_amount > 4:
		ingredient_4 = list_keys[randi_range(0, list_size - 1)]
		contents.append(ingredient_4)
	if ingredient_amount == 4:
		ingredient_4 = "bun_top_chopped"
		contents.append(ingredient_4)
	if ingredient_amount == 5:
		ingredient_5 = "bun_top_chopped"
		contents.append(ingredient_5)
	objective.emit(contents)
	update_target()

func update_target():
	var item_1 = ingredient_list[ingredient_1].instantiate()
	var item_hitbox_1 = item_1.find_child("CollisionShape3D").shape
	var item_2 = ingredient_list[ingredient_2].instantiate()
	var item_hitbox_2 = item_2.find_child("CollisionShape3D").shape
	add_child(item_1)
	item_1.remove_from_group("pickupable")
	item_1.freeze = true
	item_1.position = Vector3(0,next_position,0)
	if item_hitbox_1 is BoxShape3D:
		var item_size = item_hitbox_1.size.y
		next_position += item_size
	elif item_hitbox_1 is CylinderShape3D:
		var item_size = item_hitbox_1.height
		next_position += item_size
		
	add_child(item_2)
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
		add_child(item_3)
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
		add_child(item_4)
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
		add_child(item_5)
		item_5.freeze = true
		item_5.remove_from_group("pickupable")
		item_5.position = Vector3(0,next_position,0)
		next_position = 0
	


func _on_world_correct_order() -> void:
	for child in get_children():
		if not child.is_in_group("keep"):
			child.queue_free()
	next_position = 0.1
	contents = []
	randomise_objective()
