extends RigidBody3D
var cook_progress = 0
var cooking = false
var emitted = false
var type = "meat_cooked"
var meat_burnt = preload("res://prefabs/meat_burnt.tscn")
func _physics_process(delta: float) -> void:
	if cooking and cook_progress <= 200:
		$"../counter/stove/stove_timer".text = str(round((50-cook_progress))/10)
		cook_progress += delta * 10
	if cook_progress > 50:
		var spawned_meat_burnt = meat_burnt.instantiate()
		spawned_meat_burnt.position = position
		get_parent().add_child(spawned_meat_burnt)
		queue_free()
