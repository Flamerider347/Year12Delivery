extends Button

# Tween to increase the size of buttons when the mouse hovers
func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.2,1.2), 0.2).set_ease(Tween.EASE_OUT)

# Tween to dencrease the size of buttons when the mouse stops hove
func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.2).set_ease(Tween.EASE_OUT)
