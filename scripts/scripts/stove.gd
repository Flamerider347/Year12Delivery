extends StaticBody3D
var cooking_something = null
func _physics_process(_delta: float) -> void:
	if cooking_something:
		$Label3D.text = str(round((50-cooking_something.cook_progress))/10)

func _on_stove_body_entered(body: Node3D) -> void:
	if body.is_in_group("cookable"):
		cooking_something = body
		body.cooking = true


func _on_stove_body_exited(body: Node3D) -> void:
	if body.is_in_group("cookable"):
		cooking_something = null
		body.cooking = false
		$Label3D.text = ""
