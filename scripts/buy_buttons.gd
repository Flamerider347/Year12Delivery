extends Button
var item_cost = {
	"bench" : 50,
	"star" : [50,100,500,1000,2000,2500],
}

func _ready() -> void:
	var item = self.name.replace("buy_","")
	if item == "bench":
		button_money(item_cost["bench"])
	elif item == "star":
		button_money(item_cost["star"][$"../..".stars_bought])
func _on_pressed() -> void:
	$"../..".setup()
	var item = self.name.replace("buy_","")
	if item == "bench":
		if $"../..".benches_bought < 18:
			if item_cost[item] <= $"../../../../..".money:
				$"../..".benches_bought += 1
				$"../..".benches["bench_"+str($"../..".benches_bought)][2] = true
				$"../../layout_benches".find_child("bench_"+str($"../..".benches_bought)).show()
				for i in $"../..".benches:
					if $"../..".benches[i][2] == false:
						$"../../layout_benches".find_child(i).hide()
				$"../../../../..".money -= item_cost[item]
				$"../..".assign_layout_names()
				item_cost[item] += 50
				item_cost[item] = round(item_cost[item])
				button_money(item_cost["bench"])
				$"../..".setup()
			else:
				text = "Can't afford!"
				await get_tree().create_timer(0.5).timeout
				button_money(item_cost["bench"])
		else:
			text = "MAX LEVEL!"

	if item == "star":
		if $"../..".stars_bought < 5:
			if item_cost[item][$"../..".stars_bought] <= $"../../../../..".money:
				$"../..".stars_bought += 1
				$"../../../../..".money -= item_cost[item][$"../..".stars_bought]
				button_money(item_cost["star"][$"../..".stars_bought])
				$"../..".setup()
			else:
				text = "Can't afford!"
				await get_tree().create_timer(0.5).timeout
				button_money(item_cost["star"][$"../..".stars_bought])
		else:
			text = "MAX LEVEL!"



func button_money(cost):
	text = "$" + str(cost)
