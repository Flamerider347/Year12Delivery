extends StaticBody3D
var swinging = false
var swing_direction = 1
func _process(_delta) -> void:
	if swinging and not $"../AnimationPlayer".is_playing():
		if swing_direction == 1:
			$"../AnimationPlayer".play("door_open")
			swing_direction *= -1
			$"../Timer".stop()
			$"../Timer".start(5.0)
		else:
			$"../AnimationPlayer".play_backwards("door_open")
			swing_direction *= -1
		swinging = false



func _on_timer_timeout() -> void:
	if not $"../AnimationPlayer".is_playing():
		if swing_direction == -1:
			$"../AnimationPlayer".play_backwards("door_open")
			swing_direction *= -1
