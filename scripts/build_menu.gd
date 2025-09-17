extends Button


var hue := 0.0

func _process(delta):
	hue = fmod(hue + delta * 0.1, 1.0)
	self.modulate = Color.from_hsv(hue, 1.0, 0.7, 1.0)




func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.2,1.2), 0.2).set_ease(Tween.EASE_OUT)


func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.2).set_ease(Tween.EASE_OUT)
