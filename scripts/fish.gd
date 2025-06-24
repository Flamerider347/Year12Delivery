extends CharacterBody3D

var target = false
var switch = false
var speed = 5
var accel = 10
var target_rigid = null

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
		if Input.is_action_just_pressed("jump_p1"):
			get_target()
		if target:
			if target_rigid == $"../../player_single".held_object:
				run_away()
			var direction = Vector3()
			
			direction = nav.get_next_path_position() - global_position
			direction = direction.normalized()
			
			velocity = velocity.lerp(direction*speed, accel*delta)
			
			move_and_slide()
		if global_position.x > 120 and global_position.z > 160:
			get_target()

func get_target():
	speed = 5
	var rigid_list = []
	for i in $"../..".get_children():
		if is_instance_valid(i) and i is RigidBody3D and i.type != "knife":
			rigid_list.append(i)

	if rigid_list.size() > 0:
		target_rigid = rigid_list[randi_range(0, rigid_list.size() - 1)]
		if is_instance_valid(target_rigid):
			nav.target_position = target_rigid.global_position
			target = true

func run_away():
	target_rigid = null
	nav.target_position = Vector3(128,0,170)
	speed = 10

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == target_rigid:
		body.queue_free()
		target_rigid = null
		run_away()
