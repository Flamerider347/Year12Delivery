extends Node
var player_count = 1
var level = 1
var level_updates_left = 0
var money = 10
var stars = 3
var day_timer = 300
var benches = {}
var menu_method = "main" # could be "main", "build", "level"
var save_code #level,money,stars : <5, unlimited, <=5
var save_update = false
var unlocked_levels = {
	"level_1" :true,
	"level_2" : true,
	"level_3" : false,
	"level_4" : false,
	"level_5" : false
}
func _physics_process(_delta: float) -> void:
	if save_update:
		var parts = save_code.split("-")
		if parts.size() == 3:
			var maybe_level = int(parts[0])
			var maybe_money = int(parts[1])
			var maybe_stars = int(parts[2])
			if typeof(maybe_level) == TYPE_INT and typeof(maybe_money) == TYPE_INT and typeof(maybe_stars) == TYPE_INT and maybe_level <= 4 and maybe_stars <=5:
				level_updates_left = int(parts[0])
				print(level_updates_left)
				money = int(parts[1])
				stars = int(parts[2])
		save_update = false
	if level_updates_left >0 and level <5:
		level += 1
		var level_key = "level_%d" % (level)
		if level_key in unlocked_levels.keys():
			unlocked_levels[level_key] = true
		level_updates_left -= 1
