extends Button
signal item_purchasable
var item_cost = {
	"bench" : 20,
	
}

func _ready() -> void:
	button_money()
func _on_pressed() -> void:
	$"../..".setup()
	var item = self.name.replace("buy_","")
	if $"../..".benches_bought < 18:
		if item_cost[item] < $"../../../../..".money:
			item_purchasable.emit(item,item_cost[item])
			if item == "bench":
				item_cost[item] *= 1.5
				item_cost[item] = round(item_cost[item])
			button_money()
			$"../..".setup()
		else:
			text = "Can't afford!"
			await get_tree().create_timer(0.5).timeout
			button_money()
	else:
		text = "MAX LEVEL!"


func button_money():
	var item = self.name.replace("buy_","")
	text = "$" + str(item_cost[item])
