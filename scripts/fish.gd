extends CharacterBody3D

var target = false
var switch = false
var speed = 5
var accel = 10
var target_rigid = null
var target_position = null
var held_rigid

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
		if target:
			if target_rigid == $"../../player_single".held_object:
				run_away()
			var direction = Vector3()
			
			direction = nav.get_next_path_position() - global_position
			direction = direction.normalized()
			
			velocity = velocity.lerp(direction*speed, accel*delta)
			if velocity.length() > 0.1:
				var angle = atan2(velocity.x, velocity.z)
				rotation.y = lerp_angle(rotation.y, angle, 5 * delta)

			move_and_slide()
		if global_position.x > 120 and global_position.z > 150:
			get_target()
			rotation_degrees.y += 5
			if held_rigid:
				held_rigid.queue_free()
				held_rigid = null
			if not target_rigid:
				target = false

func get_target():
	$jaws_theme.play()
	speed = 5
	var rigid_list = []
	for i in $"../..".get_children():
		if is_instance_valid(i) and i is RigidBody3D and i.type != "knife" and i != $"../../player_single".held_object:
			rigid_list.append(i)

	if rigid_list.size() > 0:
		target_rigid = rigid_list[randi_range(0, rigid_list.size() - 1)]
		if is_instance_valid(target_rigid):
			nav.target_position = target_rigid.global_position
			target = true

func run_away():
	$jaws_theme.stop()
	target_rigid = null
	nav.target_position = Vector3(128,0,160)
	speed = 10
	target = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == target_rigid:
		body.reparent($".")
		body.position = Vector3(0,0.065,2.67)
		body.freeze = true
		body.remove_from_group("pickupable")
		body.collision_layer = 2
		body.collision_mask = 2
		held_rigid = body
		target_rigid = null
		run_away()
