extends Node2D
var editing_bench = null
var bench_type = null
@onready var menu = $"../.."
var bench_costs = {
	"bench" : 0,
	"stove" : 5,
	"chopping_board" : 5,
	"fridge": 10,
	"bun_crate" : 5,
	"bin" : 5,
}
@onready var benches = {
	"bench_1" : "bench",
	"bench_2" : "stove",
	"bench_3" : "bench",
	"bench_4" : "chopping_board",
	"bench_5" : "bun_crate",
	"bench_6" : "bench",
	"bench_7" : "bench",
	"bench_8" : "bench",
	"bench_9" : "fridge",
	"bench_10" : "bench",
	"bench_11" :"bench",
	"bench_12" : "bench",
	"bench_13" : "bench",
	"bench_14" : "bench",
	"bench_15" : "bench",
	"bench_16" : "bench",
	"bench_17" :"bench",
	"bench_18" : "bench",
}
func _ready() -> void:
	Global.benches = benches
	money_bench_check()
	print(null)
func _physics_process(_delta: float) -> void:
	if $dragging_bench.visible:
		$dragging_bench.position = get_local_mouse_position()
	if editing_bench:
		if bench_type:
			$dragging_bench.rotation_degrees = 90
	if Input.is_action_just_released("pickup_p1"):
		if bench_type:
			if editing_bench:
				var purchase_cost = 0
				purchase_cost -= int(bench_costs[benches[editing_bench]])
				purchase_cost += bench_costs[bench_type]
				benches[editing_bench] = bench_type
				print(purchase_cost)
				Global.money -= purchase_cost
				find_child(str(editing_bench)).find_child("Label").text = str(bench_type)
				$money.text = "Money: " + str(Global.money)
				money_bench_check()
		editing_bench=  null
		bench_type = null
		$dragging_bench.hide()

func money_bench_check():
	for i in get_children():
		if str(i.name) in bench_costs.keys():
			if Global.money < bench_costs[str(i.name)]:
				i.hide()
			else:
				i.show()

func _on_bench_name(bench_name) -> void:
	if bench_name:
		editing_bench = str(bench_name)

func _on_bench_bench_type(type) -> void:
	bench_type = str(type)
	$dragging_bench/Label.text = bench_type
	$dragging_bench.position = get_local_mouse_position()
	$dragging_bench.show()
	$dragging_bench.rotation_degrees = 0
