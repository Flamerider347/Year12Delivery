extends Area2D
signal bench_type
var can_edit = false
var hovering = null
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact_menu") and can_edit:
		bench_type.emit(hovering)
func _on_mouse_entered() -> void:
	can_edit = true
	hovering = self.name

func _on_mouse_exited() -> void:
	can_edit = false
