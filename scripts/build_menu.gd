extends Button


var hue := 0.0

func _process(delta):
	hue = fmod(hue + delta * 0.05, 1.0)
	self.modulate = Color.from_hsv(hue, 1.0, 1.0, 1.0)
