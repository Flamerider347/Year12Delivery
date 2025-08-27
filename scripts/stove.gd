extends StaticBody3D
var cooking_something = null

# Preloads the particles for when meat is burning on a stove.
var particle_smoke = preload("res://prefabs/particle_smoke.tscn")

func _physics_process(_delta: float) -> void:
	if cooking_something:
		$Label3D.text = str(round((50-cooking_something.cook_progress))/10)

func _on_stove_body_entered(body: Node3D) -> void:
	if body.is_in_group("cookable"):
		cooking_something = body
		body.cooking = true

	if body.is_in_group("meat"):
		if body.get_child_count() > 2 and body.get_child(2).is_in_group("particle"):
			body.get_child(2).show()



func _on_stove_body_exited(body: Node3D) -> void:
	if body.is_in_group("cookable"):
		cooking_something = null
		body.cooking = false
		$Label3D.text = ""
		if body.get_child_count() > 2 and body.get_child(2).is_in_group("particle"):
			body.get_child(2).hide()
	if body.is_in_group("meat"):
		if body.get_child_count() > 2 and body.get_child(2).is_in_group("particle"):
			body.get_child(2).hide()
