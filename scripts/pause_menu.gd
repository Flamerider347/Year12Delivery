extends CanvasLayer
var paused = false
var ingame = false
func _process(_delta: float) -> void:
	if ingame:
		if Input.is_action_just_released("menu") and paused:
			$"../ui".show()
			self.hide()
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			paused = false
		elif Input.is_action_just_released("menu") and not paused:
			$"../ui".hide()
			self.show()
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			paused = true
