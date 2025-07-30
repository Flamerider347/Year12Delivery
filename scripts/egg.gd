extends RigidBody3D

var colliding = false
var max_velocity = 0.0
var type = "egg"
var meat_cooked = preload("res://prefabs/egg_cracked.tscn")

func _physics_process(_delta: float) -> void:
	# Track peak speed
	if linear_velocity.length() > max_velocity:
		max_velocity = linear_velocity.length()

	# Check for impact and break
	if colliding and max_velocity > 2.5:
		break_egg()

func _on_area_3d_body_entered(_body: Node3D) -> void:
	colliding = true

func _on_area_3d_body_exited(_body: Node3D) -> void:
	colliding = false
	
	
func break_egg():
	var cracked_egg = meat_cooked.instantiate()
	cracked_egg.global_transform = global_transform
	get_parent().add_child(cracked_egg)
	queue_free()
