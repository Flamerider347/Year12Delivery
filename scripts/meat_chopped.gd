extends RigidBody3D
var cook_progress = 0
var cooking = false
var emitted = false
var type = "meat_chopped"
var meat_cooked = preload("res://prefabs/meat_cooked.tscn")
func _physics_process(_delta: float) -> void:
	if cooking and cook_progress <= 200:
		cook_progress += 1
	if cook_progress > 100:
		var spawned_meat_cooked = meat_cooked.instantiate()
		spawned_meat_cooked.position = position
		get_parent().add_child(spawned_meat_cooked)
		queue_free()
