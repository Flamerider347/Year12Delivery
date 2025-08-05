extends Area3D
# Audio to be played.
"res://assets/SFX/lava-bubbling-ambience.mp3"
"res://assets/SFX/underwater-currents-ambience.mp3"
"res://assets/SFX/howling-wind-ambience.mp3"


func _on_body_entered(body):
	# Creates tween variable audio manipulation
	print("entered")
	var tween = get_tree().create_tween()
	# Checks if the body enter is a player
	if body.name == "player_single" or body.name == "player" or body.name == "player2":
		# Checks which level is being played
		if $"../../..".level == 1:
			pass
		elif $"../../..".level == 2:
			$AudioStreamPlayer3D_lava.play()
			tween.tween_property($AudioStreamPlayer3D_lava, "volume_db", 0, 2)
		elif $"../../..".level == 3:
			$AudioStreamPlayer3D_underwater.play()
			tween.tween_property($AudioStreamPlayer3D_underwater, "volume_db", 0, 2)
		#elif $"../../..".level == 4:
			#$AudioStreamPlayer3D_frozen.play()
			#tween.tween_property($AudioStreamPlayer3D_frozen, "volume_db", 0, 2)
	else:
		pass

func _on_body_exited(body):
	print("exited")
	var tween = get_tree().create_tween()
	# Checks if the body enter is a player
	if body.name == "player_single" or body.name == "player" or body.name == "player2":
		# Checks which level is being played
		if $"../../..".level == 1:
			pass
		elif $"../../..".level == 2:
			tween.tween_property($AudioStreamPlayer3D_lava, "volume_db", -40, 2)
			await get_tree().create_timer(1.0).timeout
			$AudioStreamPlayer3D_lava.stop()
		elif $"../../..".level == 3:
			tween.tween_property($AudioStreamPlayer3D_underwater, "volume_db", -40, 2)
			await get_tree().create_timer(1.0).timeout
			$AudioStreamPlayer3D_underwater.stop()
		#elif $"../../..".level == 4:
			#tween.tween_property($AudioStreamPlayer3D_frozen, "volume_db", -40, 2)
			#await get_tree().create_timer(1.0).timeout
			$AudioStreamPlayer3D_frozen.stop()
