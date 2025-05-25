extends Node
var player_count = 1
var level = 1
var level_updates_left = 0
var money = 10
var stars = 3
var day_timer = 300
var recipes_list = {
	"burger" : ["bottom_bun_chopped","top_bun_chopped","cheese_chopped","lettuce_chopped","tomato_chopped","meat_cooked"],
	"stew" : ["carrot_chopped", "onion_chopped", "potato_chopped"]
}
var benches = {
	"bench_1" : ["bench",0,true],
	"bench_2" : ["fridge",0,true],
	"bench_3" : ["chopping_board",0,true],
	"bench_4" : ["stove",0,true],
	"bench_5" : ["bun_crate",0,true],
	"bench_6" : ["bench",0,true],
	"bench_7" : ["bench",270,true],
	"bench_8" : ["bench",90,false],
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
		get_tree().change_scene_to_file("res://prefabs/menu.tscn")
		money = 10
		stars = 3
		level = 1
		player_count = 1
		level_updates_left = 0
		restart = false
		for i in unlocked_levels.keys():
			unlocked_levels[i] = false
		unlocked_levels["level_1"] = true
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
