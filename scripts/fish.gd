extends CharacterBody3D

var target = false
var switch = false
var speed = 5
var accel = 10
var target_rigid: RigidBody3D = null
var held_rigid: RigidBody3D = null

var max_dist = 5.0
var max_dist_sq = max_dist * max_dist

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	if target:
		if $"../..".level != 3:
			target = false
			global_position = Vector3(125,0.75,155)
			target_rigid = null
		if target_rigid:
			$"../Label3D".show()
			if target_rigid == $"../../player_single".held_object \
			or target_rigid ==$"../../GridContainer/SubViewportContainer/SubViewport/player".held_object \
			or target_rigid == $"../../GridContainer/SubViewportContainer2/SubViewport/player2".held_object:
				run_away()
				target_rigid = null
			elif target_rigid.global_position != nav.target_position:
				nav.target_position = target_rigid.global_position
				$"../Label3D".global_position = target_rigid.global_position + Vector3(0,1,0)
			if target_rigid:
				var dx = self.global_transform.origin.x - target_rigid.global_transform.origin.x
				var dz = self.global_transform.origin.z - target_rigid.global_transform.origin.z
				var dist = sqrt(dx * dx + dz * dz)

				if dist <= 2.0:
					_on_area_3d_body_entered(target_rigid)

		else:
			run_away()

		var direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction * speed, accel * delta)

		if velocity.length() > 0.1:
			var angle = atan2(velocity.x, velocity.z)
			rotation.y = lerp_angle(rotation.y, angle, 5 * delta)

		move_and_slide()

		if global_position.x > 120 and global_position.z > 150:
			if held_rigid:
				held_rigid.queue_free()
				held_rigid = null
			if not target_rigid:
				get_target()
				$"../Label3D".hide()

func get_target():
	speed = 5
	var rigid_list: Array = []
	for i in $"../..".get_children():
		if is_instance_valid(i) and i is RigidBody3D and i.type != "knife" \
		and i != $"../../player_single".held_object \
		and i !=$"../../GridContainer/SubViewportContainer/SubViewport/player".held_object \
		and i != $"../../GridContainer/SubViewportContainer2/SubViewport/player2".held_object:
			rigid_list.append(i)

	if rigid_list.size() > 0:
		$"../Label3D".show()
		target_rigid = rigid_list[randi_range(0, rigid_list.size() - 1)]
		$"../Label3D".global_position = target_rigid.global_position + Vector3(0,1.0,0)
		if is_instance_valid(target_rigid):
			nav.target_position = target_rigid.global_position
			target = true
	else:
		target = false

func run_away():
	$"../Label3D".hide()
	target_rigid = null
	nav.target_position = Vector3(128,0,160)
	speed = 10
	target = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == target_rigid and body is RigidBody3D:
		# wait a physics frame so contacts update
		await get_tree().physics_frame
		vibrate(body)

		$"../Label3D".hide()

		body.reparent($".")
		body.position = Vector3(0,0.065,2.67)
		body.freeze = true
		body.remove_from_group("pickupable")
		body.collision_layer = 2  # layer 2
		body.collision_mask = 2   # mask 2
		held_rigid = body
		target_rigid = null
		run_away()

func vibrate(body: RigidBody3D):
	var area := $Area3D
	for collider in area.get_overlapping_bodies():
		if collider is RigidBody3D and collider != body:
			collider.sleeping = false
			# Give a small push upward + random sideways so they resettle
			var impulse = Vector3.UP * 0.2 + Vector3(randf() - 0.5, 0, randf() - 0.5) * 0.1
			collider.apply_impulse(impulse, Vector3.ZERO)
