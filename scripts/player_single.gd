extends CharacterBody3D

var speed = 0
var can_pickup = true
var controlling = false
var evil = false
var head_target_position = 0.525
var head_moving = false
var SENSITIVITY = 0.1
const WALK_SPEED = 10
const SPRINT_SPEED = 15
const JUMP_VELOCITY = 4.5
const GRAVITY = 9.81 #ms^-2
@export var controller_id: int = 0
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
				if event.axis == 5:
					if event.axis_value > 0.1 and can_pickup:
						if held_object and can_pickup:
							if stackcast.is_colliding() and stackcast.get_collider().is_in_group("stackable") and held_object.is_in_group("can_stack_" + str(stackcast.get_collider().name)):
								stack()
				if event.axis == 4 and can_pickup:
					if event.axis_value > 0.5:
						if seecast.is_colliding() and seecast.get_collider().is_in_group("interactable"):
							$interaction_timer.start(1)
						if seecast.is_colliding() and seecast.get_collider().is_in_group("door"):
							var door = seecast.get_collider()
							door.swinging = true
						if not held_object and can_pickup:
							$pickup_timer.start()
							can_pickup = false
							if seecast.is_colliding() and seecast.get_collider().is_in_group("pickupable"):
								held_object = seecast.get_collider()
								pickup(held_object)
							if seecast.is_colliding() and seecast.get_collider().is_in_group("summoner"):
								var summon_type = seecast.get_collider().name.replace("_crate","")
								summon(summon_type)
						if held_object and can_pickup:
							drop(held_object)
							$pickup_timer.start()
							can_pickup = false


		if event is InputEventJoypadButton:
			if event.device == controller_id:
				if event.button_index == JOY_BUTTON_A and is_on_floor():
					velocity.y = JUMP_VELOCITY


func _physics_process(delta: float):
	if position.y < -10:
		position = $"../kitchen".position + Vector3(0,0.5,5)
	crosshair_change()


	if controlling:
		if head_moving:
			if abs($head.position.y - head_target_position) > 0.05:
				$head.position.y = lerp($head.position.y, head_target_position, 0.2)
			else:
				head_moving = false
		if Input.is_action_just_pressed("crouch"):
			head_moving = true
			head_target_position = 0.0
		if Input.is_action_just_released("crouch"):
			head_moving = true
			head_target_position = 0.525
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
				if seecast.is_colliding() and seecast.get_collider().is_in_group("summoner"):
					var summon_type = seecast.get_collider().name.replace("_crate","")
					summon(summon_type)
			if held_object and can_pickup:
				drop(held_object)
				$pickup_timer.start()
				can_pickup = false
		if Input.is_action_just_pressed("stack"):
			if held_object and can_pickup:
				if stackcast.is_colliding() and stackcast.get_collider().is_in_group("stackable") and held_object.is_in_group("can_stack_" + str(stackcast.get_collider().name)):
					stack()
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
	if Input.is_action_pressed("crouch"):
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
	if joy_input.length() < 0.1:
		var input_dir = Input.get_vector("left", "right", "up", "down")
		direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	var cam_input = Vector2(Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_Y))


	if cam_input.length() > 0.1:
		head.rotate_y(-cam_input.x * SENSITIVITY/10)
		camera.rotate_x(-cam_input.y * SENSITIVITY/10)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))


func pickup(object):
	vibrate(object)
	if object.type == "knife":
		seecast.target_position.z = -1.8
		if $"..".is_tutorial:
			$"../tutorial/plates".pickup_knife()
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
	if $"..".level == 3 and not $"../underwater/fish".target:
		$"../underwater/fish".get_target()

func vibrate(body: RigidBody3D):
	var space := get_world_3d().direct_space_state

	var params := PhysicsShapeQueryParameters3D.new()
	params.shape = SphereShape3D.new()
	params.shape.radius = 0.75   # adjust radius
	params.transform = Transform3D(Basis(), body.global_position)
	params.collide_with_bodies = true
	params.exclude = [body]  # don't include the grabbed object

	var result = space.intersect_shape(params, 32)  # 32 = max results
	for hit in result:
		var collider = hit.collider
		if collider is RigidBody3D:
			collider.sleeping = false
			var impulse = Vector3.UP * 0.2 + Vector3(randf()-0.5, 0, randf()-0.5) * 0.1
			collider.apply_impulse(impulse, Vector3.ZERO)

func position_held_object():
	if held_object:
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
				if $"..".is_tutorial:
					if stack_bottom.contents == ["plate","bun_bottom_chopped","tomato_chopped","bun_top_chopped"]:
						$"../tutorial/plates".complete_burger()
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
			seecast.target_position.z = -3
			for i in $"../kitchen/plates".recipes_list:
				var sorted_list = $"../kitchen/plates".recipes_list[i][0].duplicate()
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


func summon(item):
	var instance = ingredient_scenes[item].instantiate()
	$"..".add_child(instance)
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
					$"../ui/Sprite2D".play("pickup")
				elif seecast.get_collider().is_in_group("summoner"):
					$"../ui/Sprite2D".play("pickup")
				elif seecast.get_collider().is_in_group("door"):
					$"../ui/Sprite2D".play("pickup")
				else:
					$"../ui/Sprite2D".play("default")
		if held_object:
			if stackcast.get_collider() != null:
				if held_object.is_in_group("can_stack_" + str(stackcast.get_collider().name)):
					$"../ui/Sprite2D".play("stacking")
				else:
					$"../ui/Sprite2D".play("default")
			else:
				$"../ui/Sprite2D".play("default")
		if not stackcast.is_colliding():
			$"../ui/Sprite2D".play("default")


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

func pause_exit() -> void:
	if $"..".world_toggle:
		$"..".world_toggle = false
		$"../pause_menu".hide()
		get_tree().paused = false
		controlling = false
		$"../GridContainer/SubViewportContainer/SubViewport/player".controlling = false
		$"../GridContainer/SubViewportContainer2/SubViewport/player2".controlling = false
		if $"../day_timer".is_stopped():
			$"../menu".win_screen()
		else:
			if $"..".level == 0:
				$"../menu".menu_toggle = true
				$"../menu".menu_load()
			else:
				$"../menu/CanvasLayer/end_screen/Control/text_you_exited".show()
				$"../menu".lose_screen()
