extends StaticBody3D
var cooking_something = null

# Preloads the particles for when meat is cooking on a stove.
var particle_smoke = preload("res://prefabs/particle_smoke.tscn")
var particle_sizzle = preload("res://prefabs/particle_sizzle.tscn")

func _physics_process(_delta: float) -> void:
	if cooking_something:
		$Label3D.text = str(round((50-cooking_something.cook_progress))/10)

func _on_stove_body_entered(body: Node3D) -> void:
	if body.is_in_group("cookable"):
		cooking_something = body
		body.cooking = true
	elif body.is_in_group("meat"):
		print("worked")
		var spawned_particle = particle_smoke.instantiate()
		body.add_child(spawned_particle)
		spawned_particle.global_position = body.global_position


func _on_stove_body_exited(body: Node3D) -> void:
	if body.is_in_group("cookable"):
		cooking_something = null
		body.cooking = false
		$Label3D.text = ""
	elif body.is_in_group("meat"):
		print(body.get_children())
		body.find_child('particle_smoke').queue_free()
