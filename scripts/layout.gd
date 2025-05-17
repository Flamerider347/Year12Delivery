extends Node2D
var editing_bench = null
var bench_type = null
var benches_bought = 7
@onready var menu = $"../.."
var bench_costs = {
	"bench" : 0,
	"stove" : 5,
	"chopping_board" : 5,
	"fridge": 10,
	"bun_crate" : 5,
	"bin" : 5,
}
@onready var benches = Global.benches
func _ready() -> void:
	money_bench_check()
	hide_benches()
	assign_layout_names()
	$upgrades.show()
	$recipes.hide()
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
				Global.money -= purchase_cost
				$layout_benches.find_child(str(editing_bench)).find_child("Label").text = str(bench_type)
				$money.text = "Money: " + str(Global.money)
				money_bench_check()
		editing_bench=  null
		bench_type = null
		$dragging_bench.hide()

func money_bench_check():
	for i in $layout_benches.get_children():
		if str(i.name) in bench_costs.keys():
			if Global.money < bench_costs[str(i.name)]:
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
			$layout_benches.find_child(i).find_child("Label").text = benches[i][0]
func _on_bench_name(bench_name) -> void:
	if bench_name:
		editing_bench = str(bench_name)

func _on_bench_bench_type(type) -> void:
	bench_type = str(type)
	$dragging_bench/Label.text = bench_type
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
		Global.money -= item_cost
		assign_layout_names()
