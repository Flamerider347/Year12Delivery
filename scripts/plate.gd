extends RigidBody3D
var contents = ["plate",]
var next_position = 0.2
var type 
func _on_player_ingredient_added(item,item_size):
	contents.append(str(item))
	next_position += item_size
