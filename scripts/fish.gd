extends CharacterBody3D

var target = false
var switch = -1
var speed = 2
var accel = 10
var target_rigid = null

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
		if Input.is_action_just_pressed("jump_p1"):
			get_target()
		if target:
			var direction = Vector3()
			
			direction = nav.get_next_path_position() - global_position
			direction = direction.normalized()
			
			velocity = velocity.lerp(direction*speed, accel*delta)
			
			move_and_slide()


func get_target():
	var rigid_list = []
	rigid_list.clear()
	for i in $"../..".get_children():
		if i is RigidBody3D:
			if i.type != "knife" and is_instance_valid(i):
				rigid_list.append(i)
	if rigid_list.size() > 0:
		print(rigid_list)
		target_rigid = rigid_list[randi_range(0,rigid_list.size())-1]
		nav.target_position = target_rigid.global_position
		target = true
		print(target_rigid)
	else:
		target_rigid = null


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == target_rigid:
		body.queue_free()
		print(str(body) + " KILLED")
		target = false
		target_rigid = null
		get_target()
