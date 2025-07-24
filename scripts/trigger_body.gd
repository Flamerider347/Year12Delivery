extends Area3D
# Audio to be played.
"res://assets/SFX/lava-bubbling-ambience.mp3"
"res://assets/SFX/underwater-currents-ambience.mp3"
"res://assets/SFX/howling-wind-ambience.mp3"


func _on_body_entered(body):
	# Creates tween variable audio manipulation
	var tween = get_tree().create_tween()
	# Checks if the body enter is a player
	if body.name == "player_single" or body.name == "player" or body.name == "player2":
		# Checks which level is being played
		if $"../../..".level == 1:
			pass
		elif $"../../..".level == 2:
			tween.tween_property($AudioStreamPlayer3D_lava, "volume_db", 0, 2)
		elif $"../../..".level == 3:
			tween.tween_property($AudioStreamPlayer3D_underwater, "volume_db", 0, 2)
		# elif $"../../..".level == 4:
			#tween.tween_property($AudioStreamPlayer3D_frozen, "volume_db", 0, 2)
	else:
		pass

func _on_body_exited(body):
	var tween = get_tree().create_tween()
	# Checks if the body enter is a player
	if body.name == "player_single" or body.name == "player" or body.name == "player2":
		# Checks which level is being played
		if $"../../..".level == 1:
			pass
		elif $"../../..".level == 2:
			tween.tween_property($AudioStreamPlayer3D_lava, "volume_db", -40, 2)
		elif $"../../..".level == 3:
			tween.tween_property($AudioStreamPlayer3D_underwater, "volume_db", -40, 2)
		# elif $"../../..".level == 4:
			#tween.tween_property($AudioStreamPlayer3D_frozen, "volume_db", -40, 2)
	else:
		pass
		
# Add timer which stops the audio from playing one the ramp off has been done.
# then audio3D.stop()
