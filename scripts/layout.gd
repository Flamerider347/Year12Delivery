extends Node2D
var editing_bench = null
var bench_type = null
@onready var menu = $"../.."
var bench_costs = {
	"bench" : 0,
	"stove" : 5,
	"chopping_board" : 5,
	"fridge": 10,
	"bin" : 5
}
@onready var benches = {
	"bench_1" : "bench",
	"bench_2" : "stove",
	"bench_3" : "fridge",
	"bench_4" : "bench",
	"bench_5" :"bench",
	"bench_6" : "bench",
	"bench_7" : "bench",
	"bench_8" : "stove",
	"bench_9" : "fridge",
	"bench_10" : "bench",
	"bench_11" :"bench",
	"bench_12" : "bench",
	"bench_13" : "bench",
	"bench_14" : "stove",
	"bench_15" : "bench",
	"bench_16" : "bench",
	"bench_17" :"bench",
	"bench_18" : "bench",
}
func _ready() -> void:
	Global.benches = benches
func _on_bench_name(bench_name) -> void:
	if bench_name in benches.keys():
		editing_bench = str(bench_name)
	if editing_bench:
		menu.layout_upgrades()
		for i in $"../layout_upgrades".get_children():
			if i.name in bench_costs.keys():
				var bench_cost = str(i.name)
				if bench_costs[bench_cost] <= Global.money:
					i.show()
				else:
					i.hide()


func _on_confirm_pressed() -> void:
	if bench_type:
		Global.money += int(bench_costs[benches[editing_bench]])
		Global.money -= bench_costs[bench_type]
		benches[editing_bench] = bench_type
		find_child(editing_bench).find_child("Label").text = bench_type
		editing_bench = null
		bench_type = null
		menu.layout()
		$money.text = "Money: " + str(Global.money)
		Global.benches = benches

func _on_bench_pressed() -> void:
	bench_type = "bench"
	confirm_button()

func _on_stove_pressed() -> void:
	bench_type = "stove"
	confirm_button()

func _on_chopping_board_pressed() -> void:
	bench_type = "chopping_board"
	confirm_button()

func _on_fridge_pressed() -> void:
	bench_type = "fridge"
	confirm_button()

func _on_bin_pressed() -> void:
	bench_type = "bin"
	confirm_button()

func confirm_button():
	$"../layout_upgrades/confirm".show()
	var purchase_cost = 0
	purchase_cost += int(bench_costs[benches[editing_bench]])
	purchase_cost -= bench_costs[bench_type]
	$"../layout_upgrades/confirm".text = "Confirm: FREE"
	if purchase_cost < 0:
		$"../layout_upgrades/confirm".text = "Confirm: -$" + str(purchase_cost).replace("-","")
	if purchase_cost > 0:
		$"../layout_upgrades/confirm".text = "Confirm: +$" + str(purchase_cost)
