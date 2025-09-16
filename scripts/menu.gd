extends Node3D
var spawn = true
var menu_toggle = true
var new_money = 0.0
var text_1 = 0.0
var text_2 = 0.0
var text_3 = 0.0
var text_4 = 0.0  # For orders delivered in endless mode
var text_5 = 0.0  # For stars remaining in endless mode
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
	_on_h_slider_5_value_changed(0.5)
	_on_h_slider_4_value_changed(0.5)
	_on_h_slider_3_value_changed(1.0)

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


func _input(event):
	#if button pressed, skips menu loading animatation
	if event.is_action_pressed("interact_menu_controller"):
		var hovered = get_viewport().gui_get_hovered_control()
		if hovered and hovered is Button:
			hovered.emit_signal("pressed")
			
		elif hovered is HSlider:
				hovered.grab_focus()
				# Optionally nudge value
				hovered.value += hovered.step  # Or -step depending on direction
			
			
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
		# Call the appropriate text function based on mode
		if $"..".level == 4:
			endless_text()
		else:
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
	$CanvasLayer/layout._on_upgrades_button_pressed()
	await show_page_with_transition($CanvasLayer/layout, "right")

func credits() -> void:
	await show_page_with_transition($CanvasLayer/credits, "right")

func options() -> void:
	await show_page_with_transition($CanvasLayer/options, "right")

func endless_screen(goal_met: bool = false):
	$"../transition animation".show()
	$"../transition animation/transition animation".play("fade_transition")
	await get_tree().create_timer(1.0).timeout

	menu_load()
	hide_everything_instant()
	reset_text()
	$CanvasLayer/book_resting_right.show()
	$CanvasLayer/end_screen.show()
	$CanvasLayer/end_screen/Control/text_you_lost.hide()
	$CanvasLayer/end_screen/Control/text_you_won.hide()
	$CanvasLayer/end_screen/Control/text_you_exited.hide()
	
	# Set the endless result text
	if goal_met:
		$CanvasLayer/end_screen/Control/endless_result.text = "GOAL MET"
	else:
		$CanvasLayer/end_screen/Control/endless_result.text = "GOAL FAILED"
	$CanvasLayer/end_screen/Control/endless_result.show()
	
	# Calculate money based on goal achievement
	visual_money = $"..".money
	if goal_met:
		# Goal met: multiply by 1 + (stars_remaining/5) * 3
		var money_multiplier = (1.0 + (float($"..".stars) / 5.0)) * 3.0
		new_money = int(round($"..".score * money_multiplier))
	else:
		# Goal not met: multiply by 1
		new_money = int(round($"..".score))
	
	$CanvasLayer/end_screen/lerp_timer.start(0.5)
	$"..".money += new_money
	$"../transition animation/transition animation".play("fade_transition_reverse")
	await get_tree().create_timer(1.0).timeout
	$"../transition animation".hide()
	endless_text()
	
	
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
	$CanvasLayer/end_screen/Control/endless_result.hide()
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
	$CanvasLayer/end_screen/Control/endless_result.hide()
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
	var req_score = float($"..".req_score)
	var initial_score = float($"..".carried_score - $"..".score)
	var carried_score = float($"..".carried_score)
	
	# Check if we're in endless mode (level 4)
	var is_endless_mode = ($"..".level == 4)
	
	if is_endless_mode:
		# Endless mode lerping
		if round(text_1) != round(req_score):
			text_1 = lerp(float(text_1), req_score, 0.05)
		elif round(text_2) != round(initial_score):
			text_2 = lerp(float(text_2), initial_score, 0.05)
		elif round(text_3) != round(score):
			text_3 = lerp(float(text_3), score, 0.05)
		elif round(visual_score) != round(carried_score):
			visual_score = lerp(float(visual_score), carried_score, 0.05)
		elif round(text_4) != round(orders_delivered):
			text_4 = lerp(float(text_4), orders_delivered, 0.05)
		elif round(text_5) != round(money):
			text_5 = lerp(float(text_5), money, 0.05)
		else:
			not_toggled = false
	else:
		# Original mode lerping
		if round(text_1) != round(score):
			text_1 = lerp(float(text_1), score, 0.05)
		elif round(text_2) != round(orders_delivered):
			text_2 = lerp(float(text_2), orders_delivered, 0.05)
		elif round(text_3) != round(stars):
			text_3 = lerp(float(text_3), stars, 0.05)
		elif round(visual_score) != round(new_money):
			visual_score = lerp(float(visual_score), float(new_money), 0.05)
		elif round(visual_money) != money:
			visual_money = lerp(float(visual_money), float(money), 0.05)
		else:
			not_toggled = false
			
func win_text():
	$CanvasLayer/end_screen/Control/stats.text = "[u]SCORE: " + str(int(round(text_1))) +" 
ORDERS: " + str(int(round(text_2))) +"
STARS: " + str(int(round(text_3))) + "
SCORE X: x" + str(score_multiplier) + "
DIFFICULTY X: x" + str(difficulty_multiplier) + "
TOTAL SCORE: " + str(int(round(new_money))) + "
MONEY: " + str(int(round(visual_money))) + "[/u]"

func endless_text():
	$CanvasLayer/end_screen/Control/stats.text = "[u]REQUIRED SCORE: " + str(int(round(text_1))) + " 
INITIAL SCORE: " + str(int(round(text_2))) +"
TODAY'S SCORE: " + str(int(round(text_3))) + "
FINAL SCORE: " + str(int(round(visual_score))) + "
ORDERS DELIVERED: " + str(int(round(text_4))) + "
MONEY: " + str(int(round(text_5))) + "[/u]"
func reset_text():
	text_1 = 0.0
	text_2 = 0.0
	text_3 = 0.0
	text_4 = 0.0
	text_5 = 0.0
	visual_score = 0.0
	visual_money = 0.0
	
	
func _on_play_level_pressed() -> void:
	$CanvasLayer/end_screen/Control/text_you_exited.hide()
	$"../player_single".can_exit = false
	$"../GridContainer/SubViewportContainer/SubViewport/player".can_exit = false
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
		$"../GridContainer/SubViewportContainer/SubViewport/player".can_exit = true
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
		$"../GridContainer/SubViewportContainer/SubViewport/player".can_exit = true
		$"../player_single".can_exit = true

func level_select_1() -> void:
	$CanvasLayer/main_menu/players_2.button_pressed = false
	$CanvasLayer/main_menu/players_1.button_pressed = true


func level_select_2() -> void:
	$"..".controllers = 0
	for i in Input.get_connected_joypads():
		if $"..".controllers < 2:
			$"..".controllers += 1
	if $"..".controllers == 2:
		$"..".player_count = 2
		$CanvasLayer/main_menu/players_1.button_pressed = false
		$CanvasLayer/main_menu/players_2.button_pressed = true
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


func _on_h_slider_3_value_changed(new_value) -> void:
	# Changes the volume of the master audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(new_value))


func _on_h_slider_4_value_changed(new_value) -> void:
	# Changes the volume of the Ambience audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), linear_to_db(new_value))


func _on_h_slider_5_value_changed(new_value) -> void:
	# Changes the volume of the SFX audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(new_value))


func _on_options_mouse_exited() -> void:
	pass # Replace with function body.


func _on_layout_mouse_exited() -> void:
	pass # Replace with function body.
