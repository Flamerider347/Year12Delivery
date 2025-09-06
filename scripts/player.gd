extends CharacterBody3D

var speed = 0
var can_pickup = true
var controlling = false
var evil = false
var controller_let_go = true
var head_target_position = 0.525
var head_moving = false
var SENSITIVITY = 0.01
const WALK_SPEED = 10
const SPRINT_SPEED = 15
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.81 #ms^-2
@export var controller_id: int = 0

# New variables for hold-to-pickup system
var l2_held = false
var l2_was_released = true  # Track if L2 was fully released
var pickup_hold_active = false
const L2_THRESHOLD = 0.3  # Threshold for considering L2 "pressed"
const L2_RELEASE_THRESHOLD = 0.1  # Threshold for considering L2 "released"

@onready var head = $head
@onready var camera = $head/player_camera
@onready var seecast = $head/player_camera/seecast
@onready var lookcast = $head/player_camera/lookcast
@onready var stackcast = $head/player_camera/stackcast

var ingredient_scenes = {
	"bun":preload("res://prefabs/bun.tscn"),
	"cheese":preload("res://prefabs/cheese.tscn"),
	"meat" : preload("res://prefabs/meat_chopped.tscn"),
	"tomato": preload("res://prefabs/tomato.tscn"),
	"lettuce": preload("res://prefabs/lettuce.tscn"),
	"carrot": preload("res://prefabs/carrot.tscn"),
	"potato": preload("res://prefabs/potato.tscn"),
	"bacon" : preload("res://prefabs/bacon.tscn"),
	"egg" :preload("res://prefabs/egg.tscn"),
	"bowl" : preload(("res://prefabs/bowl.tscn")),
	"plate": preload("res://prefabs/plate.tscn"),
	"stew" : preload("res://prefabs/stew.tscn"),
	"bacon_egg_toast" : preload("res://prefabs/bacon_egg_toast.tscn"),
}

var held_object = null  # Stores the object being held
var collision_point

signal ingredient_added
signal looking_recipe

func _setup():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	controlling = true

func _unhandled_input(event):
	if controlling:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * SENSITIVITY/200)
			camera.rotation.x = clamp(camera.rotation.x - event.relative.y * SENSITIVITY/200, deg_to_rad(-60), deg_to_rad(60))
			look_recipe()
		
		if event is InputEventJoypadMotion:
			if event.device == controller_id:
				# Handle L2 (axis 4) for pickup with hold system
				if event.axis == 4:
					handle_l2_input(event.axis_value)
				
				# Handle R2 (axis 5) for stacking
				if event.axis == 5:
					if event.axis_value > 0.1 and can_pickup:
						if held_object and pickup_hold_active:
							if stackcast.is_colliding() and stackcast.get_collider().is_in_group("stackable") and held_object.is_in_group("can_stack_" + str(stackcast.get_collider().name)):
								stack()

		if event is InputEventJoypadButton:
			if event.device == controller_id:
				if event.button_index == JOY_BUTTON_RIGHT_STICK:
					if event.pressed:
						head_moving = true
						head_target_position = 0.0
					else:
						head_moving = true
						head_target_position = 0.525
				if event.button_index == JOY_BUTTON_A and is_on_floor():
					velocity.y = JUMP_VELOCITY

func handle_l2_input(axis_value: float):
	var l2_pressed = axis_value > L2_THRESHOLD
	var l2_released = axis_value < L2_RELEASE_THRESHOLD
	
	# Update L2 release tracking
	if l2_released:
		l2_was_released = true
	
	# Handle L2 state changes
	if l2_pressed and l2_was_released and can_pickup:
		# L2 just pressed and was previously released
		l2_held = true
		l2_was_released = false
		
		if not held_object:
			# Try to pick up something
			attempt_pickup()
		
	elif not l2_pressed and l2_held:
		# L2 released while holding
		l2_held = false
		pickup_hold_active = false
		
		if held_object:
			drop(held_object)
			$pickup_timer.start()
			can_pickup = false

func attempt_pickup():
	if seecast.is_colliding():
		var collider = seecast.get_collider()
		
		# Handle interactables
		if collider.is_in_group("interactable"):
			$interaction_timer.start(1)
			return
		
		# Handle doors
		if collider.is_in_group("door"):
			var door = collider
			door.swinging = true
			return
		
		# Handle pickupable objects
		if collider.is_in_group("pickupable"):
			held_object = collider
			pickup(held_object)
			pickup_hold_active = true
		
		# Handle summoners
		elif collider.is_in_group("summoner"):
			var summon_type = collider.name.replace("_crate","")
			summon(summon_type)
			pickup_hold_active = true

func movement(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta * 1.5
		# Handle Jump.

		# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	if head_target_position == 0.0:
		speed *= 0.6
	var joy_input = Vector2(
	Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X),
	Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y),)
	if joy_input.length() < 0.1:
		joy_input = Vector2.ZERO

	var direction = (head.transform.basis * transform.basis * Vector3(joy_input.x, 0, joy_input.y)).normalized()
	velocity.x = lerp(velocity.x, direction.x * speed, delta * 7)
	velocity.z = lerp(velocity.z, direction.z * speed, delta * 7)
	# Get the input direction and handle the movement/deceleration.

	var cam_input = Vector2(Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_Y))

	if cam_input.length() > 0.1:
		head.rotate_y(-cam_input.x * SENSITIVITY * $"../../../..".sens_multiplyer)
		camera.rotate_x(-cam_input.y * SENSITIVITY * $"../../../..".sens_multiplyer)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float):
	if controlling:
		if head_moving:
			if abs($head.position.y - head_target_position) > 0.05:
				$head.position.y = lerp($head.position.y, head_target_position, 0.2)
			else:
				head_moving = false

	if position.y < -10:
		position = $"../../../../kitchen".position + Vector3(0,0.5,5)

	if controlling:
		crosshair_change()
		position_held_object()
		movement(delta)
		move_and_slide()

func pickup(object):
	if object.type == "knife":
		seecast.target_position.z = -1.8
		if $"../../../..".is_tutorial:
			$"../../../../tutorial/plates".pickup_knife()
	else:
		seecast.target_position.z = -1.6
	object.freeze = true
	object.rotation_degrees = Vector3.ZERO
	object.rotation_degrees.y = head.rotation_degrees.y
	object.linear_velocity = Vector3.ZERO
	for child in object.get_children():
		if child.is_in_group("hitbox"):
			child.disabled = true
	for child in object.get_children():
		if child is CollisionObject3D:
			seecast.add_exception(child)
	position_held_object()

func drop(object):
	if object.type == "knife":
		object.move = true
	for child in object.get_children():
		if child.is_in_group("hitbox"):
			child.disabled = false
	object.freeze = false
	held_object = null
	seecast.clear_exceptions()
	seecast.target_position.z = -3
	object.linear_velocity.y = 0.3
	if $"../../../..".level == 3 and not $"../../../../underwater/fish".target:
		$"../../../../underwater/fish".get_target()

func position_held_object():
	if held_object:
		# Drop if L2 not held (controller only)
		if not l2_held and pickup_hold_active:
			drop(held_object)
			pickup_hold_active = false
			return
		
		if held_object.rotation_degrees.y != head.rotation_degrees.y:
			held_object.rotation_degrees.y = head.rotation_degrees.y
		if seecast.is_colliding():
			collision_point = seecast.get_collision_point()
			if held_object.global_position != collision_point:
				held_object.global_position = collision_point
		else:
			if held_object.global_position != seecast.to_global(seecast.target_position):
				var target_position = seecast.to_global(seecast.target_position)
				held_object.global_position.x = lerp(held_object.global_position.x, target_position.x,0.8)
				held_object.global_position.y = lerp(held_object.global_position.y, target_position.y,0.8)
				held_object.global_position.z = lerp(held_object.global_position.z, target_position.z,0.8)

func stack():
	evil = false
	var stack_bottom = stackcast.get_collider()
	var item_shape = held_object.find_child("CollisionShape3D").shape
	if stack_bottom.type == "plate" and stack_bottom.get_child_count() == 3 and held_object.type != "bun_bottom_chopped":
		evil = true
	if not evil:
		held_object.reparent(stack_bottom)
		held_object.position = Vector3(0,stack_bottom.next_position,0)
		ingredient_added.connect(stack_bottom._on_player_ingredient_added)
		if item_shape is BoxShape3D:
			var item_size = item_shape.size.y
			ingredient_added.emit(held_object.type,item_size)
		elif item_shape is CylinderShape3D:
			var item_size = item_shape.height
			ingredient_added.emit(held_object.type,item_size)
		ingredient_added.disconnect(stack_bottom._on_player_ingredient_added)
		if held_object.type == "bun_top_chopped":
			if $"../../../..".is_tutorial:
				if stack_bottom.contents == ["plate","bun_bottom_chopped","tomato_chopped","bun_top_chopped"]:
					$"../../../../tutorial/plates".complete_burger()
			stack_bottom.add_to_group("packageable")
			stack_bottom.remove_from_group("stackable")
		held_object.rotation_degrees.x = 0
		held_object.rotation_degrees.y = randi_range(0,360)
		held_object.rotation_degrees.z = 0
		held_object.find_child("CollisionShape3D").disabled = false
		held_object.find_child("CollisionShape3D").reparent(stack_bottom)
		held_object.remove_from_group("pickupable")
		held_object.freeze = true
		held_object = null
		pickup_hold_active = false  # Reset pickup hold when stacking
		seecast.target_position.z = -3
		seecast.clear_exceptions()
		
		for i in $"../../../../kitchen/plates".recipes_list:
			if i[1]:
				var sorted_list = $"../../../../kitchen/plates".recipes_list[i][0].duplicate()
				sorted_list.sort()
				var sorted_contents = stack_bottom.contents.duplicate()
				sorted_contents.sort()
				if sorted_list == sorted_contents:
					if i in ingredient_scenes:
						var spawned_recipe = ingredient_scenes[i].instantiate()
						$"..".add_child(spawned_recipe)
						spawned_recipe.position = stack_bottom.position
						stack_bottom.queue_free()
	if evil:
		drop(held_object)
		pickup_hold_active = false

func summon(item):
	var instance = ingredient_scenes[item].instantiate()
	$"../../../..".add_child(instance)
	held_object = instance
	instance.type = str(item)
	instance.position = Vector3(0,-5,0)
	instance.add_to_group("pickupable")
	instance.add_to_group("choppable")
	instance.find_child("CollisionShape3D").disabled = true
	instance.freeze = true
	seecast.target_position.z = -1.6

func crosshair_change():
	if controlling:
		if not held_object:
			if seecast.get_collider() != null:
				if seecast.get_collider().is_in_group("pickupable"):
					$"../../../../ui/Sprite2D2".play("pickup")
				elif seecast.get_collider().is_in_group("summoner"):
					$"../../../../ui/Sprite2D2".play("pickup")
				elif seecast.get_collider().is_in_group("door"):
					$"../../../../ui/Sprite2D2".play("pickup")
				else:
					$"../../../../ui/Sprite2D2".play("default")
		if held_object:
			if stackcast.get_collider() != null:
				if held_object.is_in_group("can_stack_" + str(stackcast.get_collider().name)):
					$"../../../../ui/Sprite2D2".play("stacking")
				else:
					$"../../../../ui/Sprite2D2".play("default")
			else:
				$"../../../../ui/Sprite2D2".play("default")
		if not stackcast.is_colliding():
			$"../../../../ui/Sprite2D2".play("default")

func look_recipe():
	if lookcast.is_colliding():
		var collision_item = lookcast.get_collider()
		var emitting_collision_item = null
		if collision_item is RigidBody3D:
			if collision_item.is_in_group("packageable") or collision_item.is_in_group("stackable"):
				emitting_collision_item = collision_item.contents
				looking_recipe.emit(emitting_collision_item)
			elif collision_item.type:
				emitting_collision_item = [collision_item.type]
				looking_recipe.emit(emitting_collision_item)
		if collision_item is StaticBody3D:
			if collision_item.is_in_group("look_at"):
				emitting_collision_item = [collision_item.name.replace("_crate","")]
				looking_recipe.emit(emitting_collision_item)
			elif collision_item.is_in_group("look_at_plates"):
				if $"..".level == 0:
					emitting_collision_item = $"../tutorial/plates".plate_contents["plate_1"]
				else:
					emitting_collision_item = $"../kitchen/plates".plate_contents[collision_item.name.replace("objective_plate","plate_")]
				looking_recipe.emit(emitting_collision_item)
			else:
				looking_recipe.emit([])
		if collision_item is RigidBody3D:
			if collision_item.is_in_group("look_at"):
				emitting_collision_item = [collision_item.name]
				looking_recipe.emit(emitting_collision_item)
	else:
		$"../ui/looking_recipe".hide()

func _on_pickup_timer_timeout() -> void:
	can_pickup = true

func bounce():
	velocity.y = 8
	if held_object:
		if held_object.type  == "delivery_pot":
			held_object.find_child("Timer").start(round(held_object.time_left_timer.time_left * 0.9))
