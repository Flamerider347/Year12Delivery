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
	"bench_1" : ["bench",0,true],
	"bench_2" : ["bench",0,true],
	"bench_3" : ["bench",0,true],
	"bench_4" : ["bench",0,true],
	"bench_5" : ["bench",0,true],
	"bench_6" : ["bench",0,true],
	"bench_7" : ["bench",270,true],
	"bench_8" : ["bench",90,true],
	"bench_9" : ["bench",270,true],
	"bench_10" : ["bench",90,false],
	"bench_11" : ["bench",270,false],
	"bench_12" : ["bench",90,false],
	"bench_13" : ["bench",270,false],
	"bench_14" : ["bench",90,false],
	"bench_15" : ["bench",270,false],
	"bench_16" : ["bench",90,false],
	"bench_17" : ["bench",180,false],
	"bench_18" : ["bench",180,false],
}
func _ready() -> void:
	Global.benches = benches
	money_bench_check()
	hide_benches()
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
func hide_benches():
	for i in benches:
		if benches[i][2] == false:
			find_child(i).hide()
func _on_bench_name(bench_name) -> void:
	if bench_name:
		editing_bench = str(bench_name)

func _on_bench_bench_type(type) -> void:
	bench_type = str(type)
	$dragging_bench/Label.text = bench_type
	$dragging_bench.position = get_local_mouse_position()
	$dragging_bench.show()
	$dragging_bench.rotation_degrees = 0
