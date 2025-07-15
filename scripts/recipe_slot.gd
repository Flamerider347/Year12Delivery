extends Area2D
signal editing_recipe
func _on_mouse_entered() -> void:
	editing_recipe.emit(self.name)
