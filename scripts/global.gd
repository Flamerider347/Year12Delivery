extends Node
var player_count = 1
var level = 1
var level_updates_left = 0
var money = 500
var stars = 5
var day_timer = 20
var recipes_list = {
	"burger_ben" : [["plate","bun_bottom_chopped","meat_cooked","tomato_chopped","cheese_chopped","lettuce_chopped","bun_top_chopped"],true],
	"burger_aine" : [["plate","bun_bottom_chopped","meat_cooked","cheese_chopped","meat_cooked","bun_top_chopped"],true],
	"burger_hayden" : [["plate","bun_bottom_chopped","cheese_chopped","cheese_chopped","cheese_chopped","cheese_chopped","bun_top_chopped"],true],
	"burger_sullivan" : [["plate","bun_bottom_chopped","lettuce_chopped","tomato_chopped","cheese_chopped","carrot_chopped","bun_top_chopped",],true],
	"burger_test" :[["plate","bun_bottom_chopped","bun_top_chopped"],false],
	"stew" : [["bowl", "carrot_chopped", "meat_cooked_chopped", "potato_chopped"],false]
}
var benches = {
	"bench_1" : ["bin",0,true],
	"bench_2" : ["bench",0,true],
	"bench_3" : ["chopping_board",0,true],
	"bench_4" : ["bench",0,true],
	"bench_5" : ["fridge",0,true],
	"bench_6" : ["bun_crate",0,true],
	"bench_7" : ["stove",270,true],
	"bench_8" : ["delivery_table",90,true],
	"bench_9" : ["bench",270,false],
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
var menu_method = "main" # could be "main", "build", "level"
var save_code #level,money,stars : <5, unlimited, <=5
var save_update = false
var restart = false
var unlocked_levels = {
	"level_1" :true,
	"level_2" : true,
	"level_3" : false,
	"level_4" : false,
	"level_5" : false
}
func _physics_process(_delta: float) -> void:
	if restart:
		money = 10
		stars = 5
		level_updates_left = 0
		restart = false
	if save_update:
		var parts = save_code.split("-")
		if parts.size() == 3:
			var maybe_level = int(parts[0])
			var maybe_money = int(parts[1])
			var maybe_stars = int(parts[2])
			if typeof(maybe_level) == TYPE_INT and typeof(maybe_money) == TYPE_INT and typeof(maybe_stars) == TYPE_INT and maybe_level <= 4 and maybe_stars <=5:
				level_updates_left = int(parts[0])
				money = int(parts[1])
				stars = int(parts[2])
		save_update = false
	if level_updates_left >0 and level <5:
		level += 1
		var level_key = "level_%d" % (level)
		if level_key in unlocked_levels.keys():
			unlocked_levels[level_key] = true
		level_updates_left -= 1
