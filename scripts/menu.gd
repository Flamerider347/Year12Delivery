extends Node3D
var spawn = true
var menu_toggle = true
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
	for i in $CanvasLayer/level_select.get_children():
		if str(i.name) in Global.unlocked_levels.keys():
			if Global.unlocked_levels[str(i.name)] == false:
				i.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$"CanvasLayer/main_menu".hide()
	$CanvasLayer/level_select.hide()
	$"CanvasLayer/main_menu/players_1".modulate.a = 0
	$"CanvasLayer/main_menu/players_2".modulate.a = 0
	$"CanvasLayer/main_menu/quit".modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("pickup_p1"):
		name_thing.position.y = -2
	if name_thing.position.y > -2:
		name_thing.position.y -= delta
	else:
		if menu_toggle:
			$"CanvasLayer/main_menu".show()
			menu_toggle = false
		if $"CanvasLayer/main_menu/players_1".modulate.a <1:
			$"CanvasLayer/main_menu/players_1".modulate.a += delta
			$"CanvasLayer/main_menu/players_2".modulate.a += delta
			$"CanvasLayer/main_menu/quit".modulate.a += delta
	if spawn:
		_spawn()
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


func _on_1_player() -> void:
	$CanvasLayer/level_select.show()
	$CanvasLayer/main_menu.hide()

func _on_2_players() -> void:
	Global.player_count = 2
	get_tree().change_scene_to_file("res://prefabs/world.tscn")

func _on_level_1() -> void:
	Global.level = 1
	get_tree().change_scene_to_file("res://prefabs/world.tscn")

func _on_level_2() -> void:
	Global.level = 2
	get_tree().change_scene_to_file("res://prefabs/world.tscn")

func _on_level_3() -> void:
	Global.level = 3
	get_tree().change_scene_to_file("res://prefabs/world.tscn")

func _on_level_4() -> void:
	Global.level = 4
	get_tree().change_scene_to_file("res://prefabs/world.tscn")


func _on_level_select_return() -> void:
	$CanvasLayer/level_select.hide()
	$CanvasLayer/main_menu.show()


func _on_quit_pressed() -> void:
	get_tree().quit()
