extends CharacterBody3D

var speed = 0
var can_pickup = true
const WALK_SPEED = 10
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 5
const SENSITIVITY = 0.06
const GRAVITY = 9.81 #ms^-2
@export var controller_id: int = 0
@onready var head = $head
@onready var camera = $head/player_camera
@onready var seecast = $head/player_camera/seecast
@onready var money = $"..".money

#region ingredients
var bun = preload("res://prefabs/bun.tscn")
var cheese = preload("res://prefabs/cheese.tscn")
var meat = preload("res://prefabs/meat.tscn")
var tomato = preload("res://prefabs/tomato.tscn")
var carrot = preload("res://prefabs/carrot.tscn")
var lettuce = preload("res://prefabs/lettuce.tscn")
var ingredient_scenes = {
	"bun":bun,
	"cheese":cheese,
	"meat" : meat,
	"tomato": tomato,
	"lettuce": lettuce,
	"carrot": carrot,
}
#endregion
var held_object = null  # Stores the object being held
var collision_point

signal ingredient_added
signal money_change
func _ready():
	money_change.emit(money)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY/20)
		camera.rotate_x(-event.relative.y * SENSITIVITY/20)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	if event.device == controller_id:
		if event is InputEventJoypadButton:
			if event.button_index == JOY_BUTTON_A and event.pressed:
				if is_on_floor():
					velocity.y += JUMP_VELOCITY
		if event is InputEventJoypadButton:
			if event.button_index == JOY_BUTTON_X and can_pickup and event.pressed:
				if seecast.is_colliding() and seecast.get_collider().is_in_group("door"):
					var door = seecast.get_collider()
					door.swinging = true
				if not held_object and can_pickup:
					$pickup_timer.start()
					can_pickup = false
					if seecast.is_colliding() and seecast.get_collider().is_in_group("pickupable"):
						held_object = seecast.get_collider()
						pickup(held_object)
					if seecast.is_colliding() and seecast.get_collider().is_in_group("summoner") and money > 0:
						var summon_type = seecast.get_collider().name.replace("_crate","")
						summon(summon_type)
				if held_object and can_pickup:
					if seecast.is_colliding() and seecast.get_collider().is_in_group("stackable") and held_object.is_in_group("can_stack"):
						stack()
					else:
						drop(held_object)
					$pickup_timer.start()
					can_pickup = false
func _physics_process(delta: float):
	if money < 0:
		get_tree().change_scene_to_file("res://prefabs/menu.tscn")
	if Input.is_action_just_pressed("pickup_p1") and can_pickup:
		if seecast.is_colliding() and seecast.get_collider().is_in_group("door"):
			var door = seecast.get_collider()
			door.swinging = true
		if not held_object and can_pickup:
			$pickup_timer.start()
			can_pickup = false
			if seecast.is_colliding() and seecast.get_collider().is_in_group("pickupable"):
				held_object = seecast.get_collider()
				pickup(held_object)
			if seecast.is_colliding() and seecast.get_collider().is_in_group("summoner") and money > 0:
				var summon_type = seecast.get_collider().name.replace("_crate","")
				summon(summon_type)
		if held_object and can_pickup:
			if seecast.is_colliding() and seecast.get_collider().is_in_group("stackable") and held_object.is_in_group("can_stack"):
				stack()
			else:
				drop(held_object)
			$pickup_timer.start()
			can_pickup = false
	position_held_object()
	movement(delta)
	move_and_slide()

func movement(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta * 1.5
		# Handle Jump.
	if Input.is_action_just_pressed("jump_p1") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	var joy_input = Vector2(
	Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X),
	Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y),)

	if joy_input.length() < 0.1:
		joy_input = Vector2.ZERO

	var direction = (head.transform.basis * transform.basis * Vector3(joy_input.x, 0, joy_input.y)).normalized()
	velocity.x = lerp(velocity.x, direction.x * speed, delta * 7)
	velocity.z = lerp(velocity.z, direction.z * speed, delta * 7)
	# Get the input direction and handle the movement/deceleration.
	if joy_input.length() < 0.1:
		var input_dir = Input.get_vector("left", "right", "up", "down")
		direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	var cam_input = Vector2(Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_Y))

	if cam_input.length() > 0.1:
		head.rotate_y(-cam_input.x * SENSITIVITY)
		camera.rotate_x(-cam_input.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func pickup(object):
	object.freeze = true
	seecast.target_position.z = -1.5
	object.rotation_degrees.y = head.rotation_degrees.y
	object.linear_velocity = Vector3.ZERO
	object.position = Vector3(0,-5,0)
	for child in object.get_children():
		if child.is_in_group("hitbox"):
			child.disabled = true
	for child in object.get_children():
		if child is CollisionObject3D:
			seecast.add_exception(child)
	position_held_object()

func drop(object):
	for child in object.get_children():
		if child.is_in_group("hitbox"):
			child.disabled = false
	object.freeze = false
	held_object = null
	seecast.clear_exceptions()
	seecast.target_position.z = -3
	object.linear_velocity.y = 0.3

func position_held_object():
	if held_object:
		if seecast.is_colliding():
			collision_point = seecast.get_collision_point()
			held_object.position = collision_point
		else:
			held_object.position = seecast.to_global(seecast.target_position)

func stack():
		var stack_bottom = seecast.get_collider()
		var item_shape = held_object.find_child("CollisionShape3D").shape
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
		held_object.rotation_degrees.x = 0
		held_object.rotation_degrees.y = randi_range(0,360)
		held_object.rotation_degrees.z = 0
		held_object.find_child("CollisionShape3D").disabled = false
		held_object.find_child("CollisionShape3D").reparent(stack_bottom)
		held_object.remove_from_group("pickupable")
		held_object.freeze = true
		held_object = null

func summon(item):
	money_change.emit()
	var instance = ingredient_scenes[item].instantiate()
	$"..".add_child(instance)
	held_object = instance
	instance.type = str(item)
	instance.position = Vector3(0,-5,0)
	instance.add_to_group("pickupable")
	instance.add_to_group("choppable")
	instance.find_child("CollisionShape3D").disabled = true
	seecast.target_position.z = -1.5

func _on_pickup_timer_timeout() -> void:
	can_pickup = true

func _on_world_failed_order() -> void:
	money_change.emit()
