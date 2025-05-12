extends StaticBody3D
var swinging = false
var swing_direction = 1
var swing_power = 1
func _process(_delta) -> void:
	if swinging:
		if rotation_degrees.y < 90 and swing_direction == 1:
			rotation_degrees.y += 1 * swing_power
		elif rotation_degrees.y > 0 and swing_direction == -1:
			rotation_degrees.y -= 1 * swing_power
		else:
			swing_direction *= -1
			swinging = false
