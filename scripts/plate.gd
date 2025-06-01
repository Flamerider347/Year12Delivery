extends RigidBody3D
var contents = ["plate",]
var next_position = 0.02
var type = "plate"
func _on_player_ingredient_added(item,item_size):
	contents.append(str(item))
	next_position += item_size
