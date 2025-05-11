extends Node3D
var spawn = true
var menu_toggle = true
var save_code
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
	for i in $CanvasLayer.get_children():
		i.hide()
	if Global.menu_method == "main":
		main_menu()
		$"CanvasLayer/main_menu/players_1".modulate.a = 0
		$"CanvasLayer/main_menu/players_2".modulate.a = 0
		$"CanvasLayer/main_menu/quit".modulate.a = 0
	for i in $CanvasLayer/level_select.get_children():
		if str(i.name) in Global.unlocked_levels.keys():
			if Global.unlocked_levels[str(i.name)] == false:
				i.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		$CanvasLayer/main_menu/LineEdit.show()
		$CanvasLayer/main_menu/save_confirm.show()
	if Input.is_action_just_pressed("enter"):
		_on_save_confirm()
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

func _on_level_1() -> void:
	Global.level = 1
	_on_play_level_pressed()

func _on_level_2() -> void:
	Global.level = 2
	build_or_level()

func _on_level_3() -> void:
	Global.level = 3
	build_or_level()

func _on_level_4() -> void:
	Global.level = 4
	build_or_level()
	
func _on_level_5() -> void:
	Global.level = 5
	build_or_level()

func _on_level_select_return() -> void:
	$CanvasLayer/level_select.hide()
	$CanvasLayer/main_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_save_confirm() -> void:
	save_code = $CanvasLayer/main_menu/LineEdit.text
	if save_code:
		Global.save_code = save_code
		Global.save_update = true
	await get_tree().create_timer(0.1).timeout
	for i in $CanvasLayer/level_select.get_children():
		if str(i.name) in Global.unlocked_levels.keys():
			if Global.unlocked_levels[str(i.name)] == true:
				i.show()

func level_select():
	hide_everything()
	$CanvasLayer/level_select.show()

func main_menu():
	hide_everything()
	$name.show()
	$CanvasLayer/main_menu.show()

func build_or_level():
	hide_everything()
	$CanvasLayer/build_or_level_menu.show()
	$CanvasLayer/build_or_level_menu/play_level.text = "Play level " + str(Global.level)

func build_menu():
	hide_everything()
	$CanvasLayer/build_stuff_menu.show()

func layout():
	hide_everything()
	$CanvasLayer/layout.show()

func layout_upgrades():
	hide_everything()
	$CanvasLayer/layout.show()
	$CanvasLayer/layout_upgrades.show()
	$CanvasLayer/layout_upgrades/confirm.hide()

func _on_play_level_pressed() -> void:
	get_tree().change_scene_to_file("res://prefabs/world.tscn")

func hide_everything():
	$name.hide()
	for i in $CanvasLayer.get_children():
		i.hide()
		
func level_select_1() -> void:
	Global.player_count = 1
	level_select()


func level_select_2() -> void:
	Global.player_count = 2
	level_select()
