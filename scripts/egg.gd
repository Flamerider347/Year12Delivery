extends RigidBody3D
var type = "egg"
var meat_cooked = preload("res://prefabs/egg_cracked.tscn")
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump_p1"):
		var spawned_meat_cooked = meat_cooked.instantiate()
		spawned_meat_cooked.position = position
		get_parent().add_child(spawned_meat_cooked)
		queue_free()
