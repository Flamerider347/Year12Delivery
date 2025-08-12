extends CanvasLayer
var paused = false
var ingame = false
var mouse_speed := 1200.0  # Pixels per second
func _input(event):
	#if button pressed, skips menu loading animatation
	if ingame:
		if event.is_action_pressed("interact_menu_controller"):
			var hovered = get_viewport().gui_get_hovered_control()
			if hovered and hovered is Button:
				hovered.emit_signal("pressed")
			
func _process(delta: float) -> void:
	if ingame:
				# Get left stick vector using your input actions
		var left_stick_vector = Input.get_vector("left", "right", "up", "down")  # Vector2
		var current_mouse_pos = get_viewport().get_mouse_position()
		var new_mouse_pos = current_mouse_pos + left_stick_vector * mouse_speed * delta
		var screen_size = get_viewport().get_visible_rect().size
		new_mouse_pos = new_mouse_pos.clamp(Vector2.ZERO, screen_size)


		# Move (warp) the mouse cursor to the new position
		get_viewport().warp_mouse(new_mouse_pos)

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
