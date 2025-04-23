extends RigidBody3D
var cook_progress = 0
var cooking = false
var emitted = false
var type = "meat_cooked"
var meat_burnt = preload("res://prefabs/meat_burnt.tscn")
func _physics_process(_delta: float) -> void:
	if cooking and cook_progress <= 200:
		cook_progress += 1
	if cook_progress > 100:
		var spawned_meat_burnt = meat_burnt.instantiate()
		spawned_meat_burnt.position = position
		get_parent().add_child(spawned_meat_burnt)
		queue_free()
