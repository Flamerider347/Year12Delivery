extends Node3D
var spawn = true
var menu_toggle = true
var new_money = 0.0
var text_1 = 0.0
var text_2 = 0.0
var text_3 = 0.0
var difficulty_multiplier
var object_count = 0
var score_multiplier = 0.0
var visual_money = 0.0
var visual_score = 0.0
var not_toggled = false
var mouse_speed := 1200.0  # Pixels per second
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

# Add this variable for tweening
var is_first_load: bool = true
var is_transitioning:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#gets controller amount
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"..".controllers = 0
	for i in Input.get_connected_joypads():
		if $"..".controllers < 2:
			$"..".controllers += 1
	menu_load()
	
	
func menu_load():
	# hides fog from level 4
	$"../environment".environment.fog_enabled = false
	#loads main menu
	$"../order_timer".stop()
	$"../kitchen/plates".clear()
	$"../player_single".controlling = false
	spawn = true
	$Timer.start()
	$Camera3D.current = true
	$"../player_single/head/player_camera".current = false
	$"../GridContainer".hide()
	$"../ui".hide()
	hide_everything_instant()
	$CanvasLayer/main_menu.show()
	$CanvasLayer/book_resting_left.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_on_h_slider_5_value_changed(0.5)
	_on_h_slider_4_value_changed(0.5)
	_on_h_slider_3_value_changed(1.0)


func _input(event):
	#if button pressed, skips menu loading animatation
	if event.is_action_pressed("interact_menu_controller"):
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered and hovered is Button:
			hovered.emit_signal("pressed")
			
			
func _process(delta: float) -> void:
	# Get left stick vector using your input actions
	var left_stick_vector = Input.get_vector("left_split", "right_split", "up_split", "down_split")  # Vector2
	var current_mouse_pos = get_viewport().get_mouse_position()
	var new_mouse_pos = current_mouse_pos + left_stick_vector * mouse_speed * delta
	var screen_size = get_viewport().get_visible_rect().size
	new_mouse_pos = new_mouse_pos.clamp(Vector2.ZERO, screen_size)


	# Move (warp) the mouse cursor to the new position
	get_viewport().warp_mouse(new_mouse_pos)

	if not_toggled:
		lerp_text()
		win_text()

	if spawn:
		_spawn()
		
		
func _spawn():
	var list_keys = random_spawn.keys()
	var list_size = list_keys.size()
	var spawned_random_item = list_keys[randi_range(0,list_size-1)]
	var instance = random_spawn[spawned_random_item].instantiate()
	add_child(instance)
	instance.position = random_position()

	spawn = false

func random_position():
	var rand_place = randi_range(1,2)
	var rand_x = randi_range(7,9)
	if rand_place == 2:
		rand_x *= -1
	return Vector3(rand_x, 2.5, -1)


func _on_timer_timeout() -> void:
	spawn = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.queue_free()



func _on_level_0() -> void:
	$"..".level = 0
	_on_play_level_pressed()
	
func _on_level_1() -> void:
	$"..".level = 1
	_on_play_level_pressed()

func _on_level_2() -> void:
	$"..".level = 2
	_on_play_level_pressed()

func _on_level_3() -> void:
	$"..".level = 3
	_on_play_level_pressed()

func _on_level_4() -> void:
	$"..".level = 4
	_on_play_level_pressed()


func _on_quit_pressed() -> void:
	get_tree().quit()
	#set to reload

# New tweening functions
func hide_everything():
	# Always create a fresh tween
	var fade_out_tween = create_tween()
	
	# Get all visible children and tween them out (exclude book sprites and animation sprite)
	var visible_children = []
	for child in $CanvasLayer.get_children():
		if child.visible and child != $CanvasLayer/AnimatedSprite2D and child != $CanvasLayer/book_resting_left and child != $CanvasLayer/book_resting_right:
			visible_children.append(child)
	
	if visible_children.size() > 0:
		# Tween out all visible children
		for child in visible_children:
			fade_out_tween.parallel().tween_property(child, "modulate:a", 0.0, 0.3)
		
		# Wait for fade out to complete
		await fade_out_tween.finished
	
	# Hide all children after fade out, but don't reset alpha for book sprites
	for child in $CanvasLayer.get_children():
		if child != $CanvasLayer/AnimatedSprite2D and child != $CanvasLayer/book_resting_left and child != $CanvasLayer/book_resting_right:
			child.hide()
			child.modulate.a = 1.0  # Reset alpha for next time

func hide_everything_instant():
	# Instant hide for menu_load() - no tweening
	for i in $CanvasLayer.get_children():
		i.hide()

func show_page_with_transition(page_node: Node, flip_direction: String = "right"):
	# Prevent multiple transitions from running at once
	if is_transitioning:
		return
	
	is_transitioning = true
	
	await hide_everything()
	
	# Play book flip animation
	$CanvasLayer/AnimatedSprite2D.show()
	$CanvasLayer/AnimatedSprite2D.stop()
	$CanvasLayer/AnimatedSprite2D.play("book_flipping_" + flip_direction)
	await get_tree().create_timer(0.95).timeout
	$CanvasLayer/AnimatedSprite2D.hide()
	$CanvasLayer/AnimatedSprite2D.stop()
	
	# Show appropriate book resting sprite
	if flip_direction == "left":
		$CanvasLayer/book_resting_left.show()
	else:
		$CanvasLayer/book_resting_right.show()
	
	# Tween in the new page
	await tween_in_page(page_node)
	
	is_transitioning = false

func tween_in_page(page_node: Node):
	# Create new tween instance to avoid conflicts
	var fade_tween = create_tween()
	
	page_node.modulate.a = 0.0
	page_node.show()
	
	# Call setup if it exists (for layout page)
	if page_node.has_method("setup"):
		page_node.setup()
	
	# Tween in the new page
	fade_tween.tween_property(page_node, "modulate:a", 1.0, 0.4)
	await fade_tween.finished

# Simplified menu functions with tweening
func main_menu():
	await show_page_with_transition($CanvasLayer/main_menu, "left")

func layout():
	await show_page_with_transition($CanvasLayer/layout, "right")

func credits() -> void:
	await show_page_with_transition($CanvasLayer/credits, "right")

func options() -> void:
	await show_page_with_transition($CanvasLayer/options, "right")

func lose_screen():
	$"../transition animation".show()
	$"../transition animation/transition animation".play("fade_transition")
	await get_tree().create_timer(1.0).timeout

	menu_load()
	hide_everything_instant()
	reset_text()
	$CanvasLayer/book_resting_right.show()
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
	$"..".money += new_money
	$"../transition animation/transition animation".play("fade_transition_reverse")
	await get_tree().create_timer(1.0).timeout
	$"../transition animation".hide()
	win_text()

func win_screen():
	$"../transition animation".show()
	$"../transition animation/transition animation".play("fade_transition")
	await get_tree().create_timer(1.0).timeout

	menu_load()
	hide_everything_instant()
	reset_text()
	$CanvasLayer/book_resting_right.show()
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
	$"../transition animation".hide()
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
	$"../player_single".can_exit = false
	if $"..".level == 0:
		$"../transition animation".show()
		$"../transition animation/transition animation".play("fade_transition")
		await get_tree().create_timer(1.0).timeout
		$"../transition animation".hide()
		$"..".tutorial()
		$Camera3D.current = false
		hide_everything_instant()
		spawn = false
		$Timer.stop()
		$"../transition animation".show()
		$"../transition animation/transition animation".play("fade_transition_reverse")
		await get_tree().create_timer(1.0).timeout
		$"../transition animation".hide()
		$"../player_single".can_exit = true

	else:
		$"../transition animation".show()
		$"../transition animation/transition animation".play("fade_transition")
		await get_tree().create_timer(1.0).timeout
		$"../transition animation/transition animation".play("fade_transition_reverse")
		$".."._setup()
		hide_everything_instant()
		spawn = false
		$Timer.stop()
		await get_tree().create_timer(1.0).timeout
		$"../transition animation".hide()
		$"../player_single".can_exit = true

func level_select_1() -> void:
	$CanvasLayer/main_menu/players_2.button_pressed = false


func level_select_2() -> void:
	$"..".controllers = 0
	for i in Input.get_connected_joypads():
		if $"..".controllers < 2:
			$"..".controllers += 1
	if $"..".controllers == 2:
		$"..".player_count = 2
		$CanvasLayer/main_menu/players_1.button_pressed = false
	else:
		$CanvasLayer/main_menu/players_1.button_pressed = true
		$"..".player_count = 1
		$CanvasLayer/main_menu/players_2.button_pressed = false
		$CanvasLayer/main_menu/players_2.text = "Needs 2
		Controllers"
		await get_tree().create_timer(0.5).timeout
		$CanvasLayer/main_menu/players_2.text = "2 player"


func _on_lerp_timer_timeout() -> void:
	not_toggled = true




func _on_h_slider_value_changed(value: float) -> void:
	$CanvasLayer/options/RichTextLabel.text = "Sensitivity: " + str(value)


func _on_h_slider_2_value_changed(value:int) -> void:
	$CanvasLayer/options/RichTextLabel4.text = "Time between burger spawns: " + str(value)
	$"..".next_spawn_time = value


func _on_h_slider_3_value_changed(new_value) -> void:
	# Changes the volume of the master audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(new_value))


func _on_h_slider_4_value_changed(new_value) -> void:
	# Changes the volume of the Ambience audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), linear_to_db(new_value))


func _on_h_slider_5_value_changed(new_value) -> void:
	# Changes the volume of the SFX audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(new_value))
