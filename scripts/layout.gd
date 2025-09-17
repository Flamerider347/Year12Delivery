extends Node2D
var editing_recipe = null
var editing_bench = null
var recipe_type = null
var bench_type = null
var replaced_recipe = null
var tutorial_step = 1
var entered_unselect_area = false
var bench_type_sprites = {
	"bench" : preload("res://assets/createdassets/Icon art/Counter.png"),
	"bin" : preload("res://assets/createdassets/Icon art/Bin.png"),
	"bun_crate" : preload("res://assets/createdassets/Icon art/Pantry.png"),
	"chopping_board" : preload("res://assets/createdassets/Icon art/Counter_Cutting.png"),
	"fridge" :preload("res://assets/createdassets/Icon art/Frige.png"),
	"stove" : preload("res://assets/createdassets/Icon art/Stove.png"),
	"reciever_bench" : preload("res://assets/createdassets/Icon art/Telephone.png"),
	"delivery_table" : preload("res://assets/createdassets/Icon art/Delivery-Bench.png"),
	"burger_hayden" : preload("res://assets/createdassets/Icon art/Burger(2).png"),
	"burger_ben" : preload("res://assets/createdassets/Icon art/Burger(1).png"),
	"burger_aine" : preload("res://assets/createdassets/Icon art/Burger(3).png"),
	"burger_sullivan" : preload("res://assets/createdassets/Icon art/Burger(4).png"),
	"stew" : preload("res://assets/createdassets/Icon art/Soup.png"),
	"bacon_egg_toast" : preload("res://assets/createdassets/Icon art/Bacon&Eggs.png"),
	"unselect" : preload("res://assets/createdassets/Icon art/Rescipe_Slot.png")
}
@onready var menu = $"../.."
@onready var benches = $"../../..".benches
@onready var recipe_list = $"../../../kitchen/plates".recipes_list
var recipe_slots = ["burger_ben","burger_hayden","burger_aine",null,null,null,null,null]
func _ready() -> void:
	setup()
func setup():
	$money.text = "Money: " + str($"../../..".money)
	assign_layout_names()
	$upgrades.show()
	$recipes.hide()
func _physics_process(_delta: float) -> void:
	if $dragging_bench.visible:
		$dragging_bench.position = get_local_mouse_position()
	if editing_bench:
		if bench_type:
			$dragging_bench.rotation_degrees = benches[editing_bench][1]
	if Input.is_action_just_released("interact_menu"):
		if str(recipe_type).substr(0, str(recipe_type).length() - 1) == "recipe_slot":
			if entered_unselect_area:
				if recipe_slots[int(recipe_type.replace("recipe_slot",""))-1]:
					$recipes/selected_recipes.find_child(str(recipe_type)).show()
					$recipes/selected_recipes.find_child(str(recipe_type)).find_child("Sprite2D").texture = bench_type_sprites["unselect"]
					$recipes/available_recipes.find_child(str(recipe_slots[int(recipe_type.replace("recipe_slot",""))-1])).show()
					if recipe_slots[int(recipe_type.replace("recipe_slot",""))-1] in recipe_list.keys():
						recipe_list[recipe_slots[int(recipe_type.replace("recipe_slot",""))-1]][1] = false
						recipe_slots[int(recipe_type.replace("recipe_slot",""))-1] = null
						$"../../..".variance -= 0.2
						$recipes/Label3.text = "Recipe Variation
						Multiplier: " + str($"../../..".variance) + "x"
			else:
				$recipes/selected_recipes.find_child(str(recipe_type)).show()
			recipe_type = null
			editing_recipe = null

		elif recipe_type:
			if not entered_unselect_area and editing_recipe or editing_recipe == 0:
				if recipe_slots[editing_recipe] in recipe_list.keys():
					recipe_list[recipe_slots[editing_recipe]][1] = false
					$"../../..".variance -= 0.2
					$recipes/Label3.text = "Recipe Variation
					Multiplier: " + str($"../../..".variance) + "x"
					$recipes/available_recipes.find_child(str(recipe_slots[editing_recipe])).show()
				recipe_slots[editing_recipe] = recipe_type
				if recipe_type in recipe_list.keys():
					recipe_list[recipe_type][1] = true
					$"../../..".variance += 0.2
					$recipes/Label3.text = "Recipe Variation
					Multiplier: " + str($"../../..".variance) + "x"
					$recipes/selected_recipes.find_child("recipe_slot" + str(editing_recipe+1)).find_child("Sprite2D").texture = bench_type_sprites[recipe_type]
			else:
				$recipes/available_recipes.find_child(str(recipe_type)).show()
			recipe_type = null
			editing_recipe = null

		elif bench_type:
			if editing_bench:
				benches[editing_bench][0] = bench_type
				$layout_benches.find_child(str(editing_bench)).find_child("Sprite2D").texture = bench_type_sprites[bench_type]
				$money.text = "Money: " + str($"../../..".money)
		editing_bench =  null
		bench_type = null
		editing_recipe = null
		$dragging_bench.hide()

func assign_layout_names():
	for i in benches:
		if benches[i][2] == true:
			$layout_benches.find_child(i).find_child("Sprite2D").texture = bench_type_sprites[benches[i][0]]
			$layout_benches.find_child(i).find_child("Sprite2D").rotation_degrees = benches[i][1]
func _on_bench_name(bench_name) -> void:
	if bench_name:
		editing_bench = str(bench_name)
		
func _on_recipe_slot_editing_recipe(recipe_slot) -> void:
	editing_recipe = int(recipe_slot.replace("recipe_slot",""))-1

func _on_recipe_slot_recipe_type_unselect(type) -> void:
	if recipe_slots[int(type.replace("recipe_slot",""))-1] != null and type != "recipe_slot1":
		$recipes/selected_recipes.find_child(str(type)).hide()
		recipe_type = str(type)
		$dragging_bench.find_child("Sprite2D").texture = bench_type_sprites[recipe_slots[int(type.replace("recipe_slot",""))-1]]
		$dragging_bench.position = get_local_mouse_position()
		$dragging_bench/Sprite2D.scale = Vector2(0.04,0.04)
		$dragging_bench.show()
		$dragging_bench.rotation_degrees = 0
func _on_area_2d_recipe_type(type) -> void:
	$recipes/available_recipes.find_child(str(type)).hide()
	recipe_type = str(type)
	$dragging_bench.find_child("Sprite2D").texture = bench_type_sprites[recipe_type]
	$dragging_bench.position = get_local_mouse_position()
	$dragging_bench/Sprite2D.scale = Vector2(0.04,0.04)
	$dragging_bench.show()
	$dragging_bench.rotation_degrees = 0
func _on_bench_bench_type(type) -> void:
	bench_type = str(type)
	$dragging_bench.find_child("Sprite2D").texture = bench_type_sprites[bench_type]
	$dragging_bench.position = get_local_mouse_position()
	$dragging_bench/Sprite2D.scale = Vector2(0.023,0.023)
	$dragging_bench.show()
	$dragging_bench.rotation_degrees = 0


func _on_recipes_button_pressed() -> void:
	$upgrades.hide()
	$recipes.show()
	$upgrades_button.button_pressed = false
	$recipes_button.button_pressed = true


func _on_upgrades_button_pressed() -> void:
	$upgrades.show()
	$recipes.hide()
	$recipes_button.button_pressed = false
	$upgrades_button.button_pressed = true



func tutorial_text():
		if tutorial_step == 1:
			$layout_tutorial/tutorial_text.text = "The upgrades menu allows you to buy benches and more (just benches rn) with money (in the top left)."
		if tutorial_step == 2:
			$layout_tutorial/tutorial_text.text = "Recipes show you your recipes (next sprint you'll be able to select recipes to make)."
		if tutorial_step == 3:
			$layout_tutorial/tutorial_text.text = "Drag the icons in the bottom right above any tile to replace the tile, but building costs money."
		if tutorial_step == 4:
			$layout_tutorial/tutorial_text.text = "If you can't afford a tile, it'll disappear."
		if tutorial_step == 5:
			$layout_tutorial/tutorial_text.text = "The ? in the top right can reopen the tutorial if you get stuck."

func _on_open_tutorial() -> void:
	$layout_tutorial.show()
	tutorial_step = 1
	tutorial_text()
	
func _on_back_pressed() -> void:
	if tutorial_step > 1:
		tutorial_step -= 1
		tutorial_text()

func _on_next_pressed() -> void:
	if tutorial_step < 5:
		tutorial_step += 1
		tutorial_text()
func _on_close_pressed() -> void:
	$layout_tutorial.hide()


func _on_unselect_area_mouse_entered() -> void:
	entered_unselect_area = true


func _on_unselect_area_mouse_exited() -> void:
	entered_unselect_area = false


func _on_unselect_area_mouse_exited_bench() -> void:
	editing_bench = null
