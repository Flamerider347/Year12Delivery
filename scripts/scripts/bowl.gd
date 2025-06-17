extends RigidBody3D
var contents = ["bowl",]
var next_position = 0
var type 
func _on_player_ingredient_added(item,_item_size):
	contents.append(str(item))
