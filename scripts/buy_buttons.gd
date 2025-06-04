extends Button
signal item_purchasable
var item_cost = {
	"bench" : 20,
	
}

func _ready() -> void:
	button_money()
func _on_pressed() -> void:
	var item = self.name.replace("buy_","")
	if item_cost[item] < Global.money:
		item_purchasable.emit(item,item_cost[item])
		if item == "bench":
			item_cost[item] *= 1.5
			item_cost[item] = round(item_cost[item])
		button_money()
		$"../../money".text = "Money: " + str(Global.money)
	else:
		text = "Can't afford!"
		await get_tree().create_timer(0.5).timeout
		button_money()

func button_money():
	var item = self.name.replace("buy_","")
	text = "$" + str(item_cost[item])
