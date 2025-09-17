extends Button
var benches_bought = 7
var stars_bought = 1
var recipe_slots_bought = 4
var item_cost = {
	"bench" : 50,
	"star" : [50,100,500,1000,2000,2500],
	"recipe_slot" : [1,2,3,4,100,250,500,1000,2000]
}

func _ready() -> void:
	var item = self.name.replace("buy_","")
	if item == "bench":
		button_money(item_cost["bench"])
	elif item == "star":
		button_money(item_cost["star"][stars_bought])
	elif item == "recipe_slot":
		button_money(item_cost["recipe_slot"][recipe_slots_bought])
func _on_pressed() -> void:
	
	var item = self.name.replace("buy_","")
	if item == "bench":
		if benches_bought < 17:
			if item_cost[item] <= $"../../../../..".money:
				$"../../../../..".money -= item_cost[item]
				$"../../money".text = "Money: " + str($"../../../../..".money)
				benches_bought += 1
				$"../..".benches["bench_"+str(benches_bought)][2] = true
				$"../../layout_benches".find_child("bench_"+str(benches_bought)).show()
				for i in $"../..".benches:
					if $"../..".benches[i][2] == false:
						$"../../layout_benches".find_child(i).hide()
				$"../..".assign_layout_names()
				item_cost[item] += 50
				item_cost[item] = round(item_cost[item])
				button_money(item_cost["bench"])
				$"../bench".text = "Space " + str(benches_bought+2) + "
-Adds another customisable bench. 
-More benches speed up production."
				if benches_bought == 17:
					text = "MAX LEVEL!"
					$"../bench".text = "Max Space
-Adds another customisable bench. 
-More benches speed up production."
			else:
				text = "Can't afford!"
				await get_tree().create_timer(0.5).timeout
				button_money(item_cost["bench"])
		else:
			text = "MAX LEVEL!"

	if item == "star":
		if stars_bought < 5:
			if item_cost[item][stars_bought] <= $"../../../../..".money:
				$"../../../../..".money -= item_cost[item][stars_bought]
				$"../../money".text = "Money: " + str($"../../../../..".money)
				stars_bought += 1
				$"../../../../..".stars = stars_bought
				button_money(item_cost["star"][stars_bought])
				$"../star".text = "Star " + str(stars_bought+1) + "
-Stars allow you to fail orders. 
-More stars means more money!"
				if stars_bought == 5:
					text = "MAX LEVEL!"
					$"../star".text = "Max Stars
-Stars allow you to fail orders. 
-More stars means more money!"
			else:
				text = "Can't afford!"
				await get_tree().create_timer(0.5).timeout
				button_money(item_cost["star"][stars_bought])
		else:
			text = "MAX LEVEL!"

	if item == "recipe_slot":
		if recipe_slots_bought < 6:
			if item_cost[item][recipe_slots_bought] <= $"../../../../..".money:
				$"../../../../..".money -= item_cost[item][recipe_slots_bought]
				$"../../money".text = "Money: " + str($"../../../../..".money)
				recipe_slots_bought += 1
				button_money(item_cost[item][recipe_slots_bought])
				$"../../recipes/selected_recipes".find_child("recipe_slot"+str(recipe_slots_bought)).show()
				$"../recipe_slot".text = "Slot " + str(recipe_slots_bought+1) + "
-Cook more recipes at one time
-Change equipped slots in Recipes"
				if recipe_slots_bought == 6:
					text = "MAX LEVEL!"
					$"../recipe_slot".text = "Max Slots
-Cook more recipes at one time
-Change equipped slots in Recipes"
			else:
				text = "Can't afford!"
				await get_tree().create_timer(0.5).timeout
				button_money(item_cost["recipe_slot"][recipe_slots_bought])
		else:
			text = "MAX LEVEL!"




func button_money(cost):
	text = "$" + str(cost)



# Tween to increase the size of buttons when the mouse hovers
func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1,1.1), 0.2).set_ease(Tween.EASE_OUT)

# Tween to dencrease the size of buttons when the mouse stops hove
func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.2).set_ease(Tween.EASE_OUT)
