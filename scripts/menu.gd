extends Node3D
var spawn = true
var menu_toggle = true
var save_code
var new_money = 0.0
var text_1 = 0.0
var text_2 = 0.0
var text_3 = 0.0
var difficulty_multiplier
var score_multiplier = 0.0
var visual_money = 0.0
var visual_score = 0.0
var not_toggled = false
var mouse_speed := 1200.0  # Pixels per second
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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"..".controllers = 0
	for i in Input.get_connected_joypads():
		if $"..".controllers < 2:
			$"..".controllers += 1
	menu_load()
func menu_load():
	$"../order_timer".stop()
	$"../kitchen/plates".clear()
	$"../player_single".controlling = false
	name_thing.position.y = 0.5
	spawn = true
	$Timer.start()
	$Camera3D.current = true
	$"../player_single/head/player_camera".current = false
	$"../GridContainer".hide()
	$"../ui".hide()
	hide_everything()
	$name.show()
	$"CanvasLayer/main_menu/players_1".modulate.a = 0
	$"CanvasLayer/main_menu/players_2".modulate.a = 0
	$"CanvasLayer/main_menu/quit".modulate.a = 0
	$"CanvasLayer/main_menu/options".modulate.a = 0
	$"CanvasLayer/main_menu/credits".modulate.a = 0
	for i in $CanvasLayer/level_select.get_children():
		if str(i.name) in $"..".unlocked_levels.keys():
			if $"..".unlocked_levels[str(i.name)] == false:
				i.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("ui_accept"):
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered and hovered is Button:
			hovered.emit_signal("pressed")
func _process(delta: float) -> void:
	# Get left stick vector using your input actions
	var left_stick_vector = Input.get_vector("left", "right", "up", "down")  # Vector2
	var current_mouse_pos = get_viewport().get_mouse_position()
	var new_mouse_pos = current_mouse_pos + left_stick_vector * mouse_speed * delta
	var screen_size = get_viewport().get_visible_rect().size
	new_mouse_pos = new_mouse_pos.clamp(Vector2.ZERO, screen_size)


	# Move (warp) the mouse cursor to the new position
	get_viewport().warp_mouse(new_mouse_pos)

	if not_toggled:
		lerp_text()
		win_text()

	if Input.is_action_just_pressed("down"):
		$CanvasLayer/main_menu/LineEdit.show()
		$CanvasLayer/main_menu/save_confirm.show()

	if Input.is_action_just_pressed("enter"):
		_on_save_confirm()
	if Input.is_action_just_released("pickup_p1"):
		name_thing.position.y = -2

	if name_thing.position.y > -2:
		name_thing.position.y -= delta
	else:
		if menu_toggle:
			hide_everything()
			main_menu()
			menu_toggle = false
		if $"CanvasLayer/main_menu/players_1".modulate.a < 1:
			$"CanvasLayer/main_menu/players_1".modulate.a += delta
			$"CanvasLayer/main_menu/players_2".modulate.a += delta
			$"CanvasLayer/main_menu/quit".modulate.a += delta
			$"CanvasLayer/main_menu/options".modulate.a += delta
			$"CanvasLayer/main_menu/credits".modulate.a += delta

	if spawn:
		_spawn()
func _spawn():
	var list_keys = random_spawn.keys()
	var list_size = list_keys.size()
	var spawned_random_item = list_keys[randi_range(0,list_size-1)]
	var instance = random_spawn[spawned_random_item].instantiate()
	add_child(instance)
	instance.position = Vector3(randf_range(-3,3),1,randf_range(-3,3))
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
	$"..".player_count = 2

func _on_level_0() -> void:
	$"..".level = 0
	_on_play_level_pressed()
	
func _on_level_1() -> void:
	$"..".level = 1
	_on_play_level_pressed()

func _on_level_2() -> void:
	$"..".level = 2
	build_or_level()

func _on_level_3() -> void:
	$"..".level = 3
	build_or_level()

func _on_level_4() -> void:
	$"..".level = 4
	build_or_level()
	
func _on_level_5() -> void:
	$"..".level = 5
	build_or_level()

func _on_level_select_return() -> void:
	$CanvasLayer/level_select.hide()
	$CanvasLayer/main_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_save_confirm() -> void:
	save_code = $CanvasLayer/main_menu/LineEdit.text
	if save_code:
		$"..".save_code = save_code
		$"..".save_update = true
	await get_tree().create_timer(0.1).timeout
	for i in $CanvasLayer/level_select.get_children():
		if str(i.name) in $"..".unlocked_levels.keys():
			if $"..".unlocked_levels[str(i.name)] == true:
				i.show()

func level_select():
	hide_everything()
	$CanvasLayer/level_select.show()

func main_menu():
	hide_everything()
	$CanvasLayer/main_menu/LineEdit.hide()
	$CanvasLayer/main_menu/save_confirm.hide()
	$name.show()
	$CanvasLayer/main_menu.show()

func build_or_level():
	hide_everything()
	$CanvasLayer/build_or_level_menu.show()
	$CanvasLayer/build_or_level_menu/play_level.text = "Play Level " + str($"..".level)

func layout():
	hide_everything()
	$CanvasLayer/layout.show()
	$CanvasLayer/layout.setup()

func lose_screen():
	$"../transition animation".show()
	$"../transition animation/transition animation".play("fade_transition")
	await get_tree().create_timer(1.0).timeout

	menu_load()
	hide_everything()
	reset_text()
	$CanvasLayer/end_screen.show()
	$CanvasLayer/end_screen/Control/text_you_lost.hide()
	if not $CanvasLayer/end_screen/Control/text_you_exited.is_visible_in_tree():
		$CanvasLayer/end_screen/Control/text_you_lost.show()
	$CanvasLayer/end_screen/Control/text_you_won.hide()
	score_multiplier = ($"..".stars/5.0)
	difficulty_multiplier = $"..".level
	visual_money = $"..".money
	new_money = int(round($"..".score * difficulty_multiplier * score_multiplier))
	$CanvasLayer/end_screen/lerp_timer.start(0.5)
	$"../transition animation/transition animation".play("fade_transition_reverse")
	await get_tree().create_timer(1.0).timeout
	win_text()

func win_screen():
	$"../transition animation".show()
	$"../transition animation/transition animation".play("fade_transition")
	await get_tree().create_timer(1.0).timeout

	menu_load()
	hide_everything()
	reset_text()
	$CanvasLayer/end_screen.show()
	$CanvasLayer/end_screen/Control/text_you_lost.hide()
	$CanvasLayer/end_screen/Control/text_you_won.show()
	score_multiplier = (1+$"..".stars/5.0)
	difficulty_multiplier = $"..".level
	visual_money = $"..".money
	new_money = int(round($"..".score * difficulty_multiplier * score_multiplier))
	$CanvasLayer/end_screen/lerp_timer.start(0.5)
	$"..".money += new_money
	$"../transition animation/transition animation".play("fade_transition_reverse")
	await get_tree().create_timer(1.0).timeout
	win_text()

func lerp_text():
	var score = float($"..".score)
	var orders_delivered = float($"..".orders_delivered)
	var stars = float($"..".stars)
	var money = float($"..".money)
	if round(text_1) != round(score):
		text_1 = lerp(float(text_1),score,0.05)
	elif round(text_2) != round(orders_delivered):
		text_2 = lerp(float(text_2),orders_delivered,0.05)
	elif round(text_3) != round(stars):
		text_3 = lerp(float(text_3),stars,0.05)
	elif round(visual_score) != round(new_money):
		visual_score = lerp(float(visual_score),float(new_money),0.05)
	elif round(visual_money) != money:
		visual_money = lerp(float(visual_money), float(money),0.05)
	else:
		not_toggled = false

func win_text():
	$CanvasLayer/end_screen/Control/stats.text = "[u]SCORE: " + str(int(round(text_1))) +" 
ORDERS DELIVERED: " + str(int(round(text_2))) +"
STARS REMAINING: " + str(int(round(text_3))) + "
SCORE MULTIPLIER: x" + str(score_multiplier) + "
DIFFICULTY MULTIPLIER: x" + str(difficulty_multiplier) + "
TOTAL SCORE: " + str(int(round(new_money))) + "
MONEY: " + str(int(round(visual_money))) + "[/u]"
func reset_text():
	text_1 = 0.0
	text_2 = 0.0
	text_3 = 0.0
	visual_score = 0.0
	visual_money = 0.0

func _on_play_level_pressed() -> void:
	$CanvasLayer/end_screen/Control/text_you_exited.hide()
	if $"..".level == 0:
		$"../transition animation".show()
		$"../transition animation/transition animation".play("fade_transition")
		await get_tree().create_timer(1.0).timeout
		$"../transition animation".hide()
		$"..".tutorial()
		$Camera3D.current = false
		hide_everything()
		spawn = false
		$Timer.stop()
		$"../transition animation/transition animation".play("fade_transition_reverse")
		await get_tree().create_timer(1.0).timeout
		$"../transition animation".hide()

	else:
		$"../transition animation".show()
		$"../transition animation/transition animation".play("fade_transition")
		await get_tree().create_timer(1.0).timeout
		$"../transition animation/transition animation".play("fade_transition_reverse")
		$".."._setup()
		hide_everything()
		spawn = false
		$Timer.stop()
		await get_tree().create_timer(1.0).timeout
		$"../transition animation".hide()
func hide_everything():
	$name.hide()
	for i in $CanvasLayer.get_children():
		i.hide()
		
func level_select_1() -> void:
	$"..".player_count = 1
	level_select()

func level_select_2() -> void:
	$"..".player_count = 2
	level_select()


func _on_lerp_timer_timeout() -> void:
	not_toggled = true


func credits() -> void:
	hide_everything()
	$CanvasLayer/credits.show()


func options() -> void:
	hide_everything()
	$CanvasLayer/options.show()


func _on_h_slider_value_changed(value: float) -> void:
	$CanvasLayer/options/RichTextLabel.text = "Sensitivity: " + str(value)


func _on_h_slider_2_value_changed(value:int) -> void:
	$CanvasLayer/options/RichTextLabel2.text = "Time between burger spawns: " + str(value)
	$"..".next_spawn_time = value
