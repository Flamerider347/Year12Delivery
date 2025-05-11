extends Node2D
var editing_bench = null
var bench_type = null
@onready var menu = $"../.."
var bench_costs = {
	"bench" : 0,
	"stove" : 5
}
@onready var benches = {
	"bench_1" : "bench",
	"bench_2" : "bench"
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
	$"../layout_upgrades/confirm".show()

func _on_stove_pressed() -> void:
	bench_type = "stove"
	$"../layout_upgrades/confirm".show()
