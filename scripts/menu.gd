extends Node3D
var spawn = true
@onready var name_thing = $name
var bun = preload("res://prefabs/bun.tscn")
var cheese = preload("res://prefabs/cheese.tscn")
var meat = preload("res://prefabs/meat.tscn")
var tomato = preload("res://prefabs/tomato.tscn")
var carrot = preload("res://prefabs/carrot.tscn")
var lettuce = preload("res://prefabs/lettuce.tscn")
var random_spawn = {
	"bun":bun,
	"cheese":cheese,
	"meat" : meat,
	"tomato": tomato,
	"lettuce": lettuce,
	"carrot": carrot,
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"CanvasLayer/1".hide()
	$"CanvasLayer/1".modulate.a = 0
	$"CanvasLayer/2".hide()
	$"CanvasLayer/2".modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("pickup_p1"):
		name_thing.position.y = -2
	if name_thing.position.y > -2:
		name_thing.position.y -= delta
	else:
		$"CanvasLayer/1".show()
		if $"CanvasLayer/1".modulate.a <1:
			$"CanvasLayer/1".modulate.a += delta
		$"CanvasLayer/2".show()
		if $"CanvasLayer/2".modulate.a <1:
			$"CanvasLayer/2".modulate.a += delta
	if spawn:
		_spawn()
func _on_button_pressed() -> void:
	Global.button_value = 1
	get_tree().change_scene_to_file("res://prefabs/world.tscn")
func _on_pressed_2() -> void:
	Global.button_value = 2
	get_tree().change_scene_to_file("res://prefabs/world.tscn")

func _spawn():
	var list_keys = random_spawn.keys()
	var list_size = list_keys.size()
	var spawned_random_item = list_keys[randi_range(0,list_size-1)]
	var instance = random_spawn[spawned_random_item].instantiate()
	add_child(instance)
	instance.position = Vector3(randf_range(-3,3),10,randf_range(-3,3))
	instance.rotation_degrees = Vector3(randi_range(0,360),randi_range(0,360),randi_range(0,360))
	spawn = false
	$Timer.start()


func _on_timer_timeout() -> void:
	spawn = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	body.queue_free()
