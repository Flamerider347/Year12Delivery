extends StaticBody3D

@onready var timer = $"../../../order_timer"
var timer_timedout = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $Timer.time_left:
		$Label3D.text = str(round($Timer.time_left*10.0)/10.0)
	else:
		$Label3D.text = "READY"

func get_call():
	
	timer.stop()
	timer.start(50)
	var can_call = $"../../..".orders.has(0)
	if timer_timedout and can_call:
		$"../../.."._on_order_timer_timeout()
		$Timer.start(5.0)
		timer_timedout = false
	else:
		pass


func _on_timer_timeout() -> void:
		timer_timedout = true
		$Timer.stop()
