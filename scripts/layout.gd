extends Node2D
var editing_bench = null
var bench_type = null
var benches_bought = 0
var tutorial_step = 1
var bench_type_sprites = {
	"bench" : preload("res://assets/Sprint 1 Icons for benches/Bench.png"),
	"bin" : preload("res://assets/Sprint 1 Icons for benches/Bin Crate.png"),
	"bun_crate" : preload("res://assets/Sprint 1 Icons for benches/Screenshot 2025-06-25 192059.png"),
	"chopping_board" : preload("res://assets/Sprint 1 Icons for benches/Chopping Board.png"),
	"fridge" :preload("res://assets/Sprint 1 Icons for benches/Fridge.png"),
	"stove" : preload("res://assets/Sprint 1 Icons for benches/Stove.png"),
	"delivery_table" : preload("res://assets/Sprint 1 Icons for benches/delivery_plate.png")
}
@onready var menu = $"../.."
var bench_costs = {
	"bench" : 0,
	"stove" : 5,
	"chopping_board" : 5,
	"fridge": 10,
	"bun_crate" : 5,
	"bin" : 5,
	"delivery_table" : 10
}
@onready var benches = $"../../..".benches
func _ready() -> void:
	setup()
func setup():
	$money.text = "Money: " + str($"../../..".money)
	money_bench_check()
	hide_benches()
	assign_layout_names()
	$upgrades.show()
	$recipes.hide()
	benches_bought = 0
	for i in $"../../..".benches.keys():
		if $"../../..".benches[i][2] == true:
			benches_bought += 1
		else:
			break
	if benches_bought == 18:
		$upgrades/buy_bench.text = "MAX LEVEL!"
func _physics_process(_delta: float) -> void:
	if $dragging_bench.visible:
		$dragging_bench.position = get_local_mouse_position()
	if editing_bench:
		if bench_type:
			$dragging_bench.rotation_degrees = benches[editing_bench][1]
	if Input.is_action_just_released("pickup_p1"):
		if bench_type:
			if editing_bench:
				var purchase_cost = 0
				purchase_cost -= int(bench_costs[benches[editing_bench][0]])
				purchase_cost += bench_costs[bench_type]
				benches[editing_bench][0] = bench_type
				$"../../..".money -= purchase_cost
				$layout_benches.find_child(str(editing_bench)).find_child("Sprite2D").texture = bench_type_sprites[bench_type]
				$money.text = "Money: " + str($"../../..".money)
				money_bench_check()
		editing_bench=  null
		bench_type = null
		$dragging_bench.hide()

func money_bench_check():
	for i in $layout_shop.get_children():
		if str(i.name) in bench_costs.keys():
			if $"../../..".money < bench_costs[str(i.name)]:
				i.hide()
			else:
				i.show()
func hide_benches():
	for i in benches:
		if benches[i][2] == false:
			find_child(i).hide()

func assign_layout_names():
	for i in benches:
		if benches[i][2] == true:
			$layout_benches.find_child(i).find_child("Sprite2D").texture = bench_type_sprites[benches[i][0]]
			$layout_benches.find_child(i).find_child("Sprite2D").rotation_degrees = benches[i][1]
func _on_bench_name(bench_name) -> void:
	if bench_name:
		editing_bench = str(bench_name)

func _on_bench_bench_type(type) -> void:
	bench_type = str(type)
	$dragging_bench.find_child("Sprite2D").texture = bench_type_sprites[bench_type]
	$dragging_bench.position = get_local_mouse_position()
	$dragging_bench.show()
	$dragging_bench.rotation_degrees = 0


func _on_recipes_button_pressed() -> void:
	$upgrades.hide()
	$recipes.show()


func _on_upgrades_button_pressed() -> void:
	$upgrades.show()
	$recipes.hide()

func _on_item_purchasable(item,item_cost) -> void:
	if item == "bench":
		if benches_bought < 18:
			benches_bought += 1
		benches["bench_"+str(benches_bought)][2] = true
		$layout_benches.find_child("bench_"+str(benches_bought)).show()
		for i in benches:
			if benches[i][2] == false:
				$layout_benches.find_child(i).hide()
		$"../../..".money -= item_cost
		assign_layout_names()



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
