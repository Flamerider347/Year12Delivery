extends RigidBody3D
var cook_progress = 0
var cooking = false
var emitted = false
var type = "meat_chopped"
var meat_cooked = preload("res://prefabs/meat_cooked.tscn")
func _physics_process(delta: float) -> void:
	if cooking and cook_progress <= 200:
		$"../counter/stove/Label3D".text = str(round((50-cook_progress))/10)
		cook_progress += delta * 10
	if cook_progress > 50:
		var spawned_meat_cooked = meat_cooked.instantiate()
		spawned_meat_cooked.position = position
		get_parent().add_child(spawned_meat_cooked)
		queue_free()
