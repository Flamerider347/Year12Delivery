extends RigidBody3D
var cook_progress = 0
var cooking = false
var emitted = false
var type = "meat_cooked"
var toggled = false
var meat_burnt = preload("res://prefabs/meat_burnt.tscn")
var particle_sizzle = preload("res://prefabs/particle_sizzle.tscn")
func _physics_process(delta: float) -> void:
	if cooking and cook_progress <= 200:
		cook_progress += delta * 10
		if not toggled:
			var spawned_particle = particle_sizzle.instantiate()
			add_child(spawned_particle)
			toggled = true
	if cook_progress > 50:
		var spawned_meat_burnt = meat_burnt.instantiate()
		spawned_meat_burnt.position = position
		get_parent().add_child(spawned_meat_burnt)
		queue_free()
