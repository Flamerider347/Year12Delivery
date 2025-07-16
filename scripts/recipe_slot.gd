extends Area2D
signal editing_recipe
signal recipe_type
var can_edit = false
var hovering = null

func _physics_process(_delta: float) -> void:
	if can_edit and Input.is_action_just_pressed("pickup_p1"):
		hovering = self.name
		recipe_type.emit(hovering)
func _on_mouse_entered() -> void:
	can_edit = true
	editing_recipe.emit(self.name)

func _on_mouse_exited() -> void:
	can_edit = false
