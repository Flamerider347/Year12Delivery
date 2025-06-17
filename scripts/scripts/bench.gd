extends Area2D
signal bench_name
var can_edit = false
var hovering = null

func _on_mouse_entered() -> void:
	hovering = self.name
	bench_name.emit(hovering)

func _on_mouse_exited() -> void:
	hovering = null
	bench_name.emit(hovering)
