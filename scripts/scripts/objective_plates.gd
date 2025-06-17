extends StaticBody3D
signal timed_out_timer



func _on_order_time_timeout() -> void:
	var number = int(str(self.name).replace("objective_plate",""))
	timed_out_timer.emit(number)
