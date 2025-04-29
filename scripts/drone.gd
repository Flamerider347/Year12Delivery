extends CharacterBody3D
var speed = 0
var can_pickup = true
var can_swap = false
var control = false
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const SENSITIVITY = 0.002

@onready var head = $head
@onready var camera = $head/player_camera
@onready var seecast = $head/player_camera/seecast

var held_object = null  # Stores the object being held
var collision_point

signal player_switch
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float):
	if held_object:
		if seecast.is_colliding():
			collision_point = seecast.get_collision_point()
			held_object.position = collision_point
		else:
			held_object.position = seecast.to_global(seecast.target_position)
	if Input.is_action_just_pressed("pickup") and not held_object and can_pickup:
		can_pickup = false
		$pickup_timer.start()
		if seecast.is_colliding() and seecast.get_collider().is_in_group("pickupable"):
			held_object = seecast.get_collider()
			pickup(held_object)
	if Input.is_action_just_pressed("pickup") and held_object and can_pickup:
		can_pickup = false
		$pickup_timer.start()
		drop(held_object)

	movement(delta)
	move_and_slide()
func movement(delta):
	if Input.is_action_just_pressed("jump"):
		position.y += speed
	
		# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
	velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)

func pickup(object):
	object.freeze = true
	seecast.target_position.z = -1.5
	object.rotation_degrees.y = head.rotation_degrees.y
	object.linear_velocity = Vector3.ZERO
	for child in object.get_children():
		if child.is_in_group("hitbox"):
			child.disabled = true
	for child in object.get_children():
		if child is CollisionObject3D:
			seecast.add_exception(child)
func drop(object):
	for child in object.get_children():
		if child.is_in_group("hitbox"):
			child.disabled = false
	object.freeze = false
	held_object = null
	seecast.clear_exceptions()
	seecast.target_position.z = -3
	object.linear_velocity.y = 0.3

func _on_pickup_timer_timeout() -> void:
	can_pickup = true

func _on_player_drone_swap() -> void:
	control = true

func _on_swap_timer_timeout() -> void:
	can_swap = true
