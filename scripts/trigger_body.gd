extends Area3D
# Audio to be played.
"res://assets/SFX/lava-bubbling-ambience.mp3"
"res://assets/SFX/underwater-currents-ambience.mp3"
"res://assets/SFX/howling-wind-ambience.mp3"
@onready var tween = get_tree().create_tween()

func _on_body_entered(body):
	# Creates tween variable audio manipulation
	# Checks if the body enter is a player
	if body.name == "player_single" or body.name == "player" or body.name == "player2":
		# Checks which level is being played
		if $"../../..".level == 1:
			pass
		elif $"../../..".level == 2:
			# Starts to play the audio from the player
			$AudioStreamPlayer3D_lava.play()
			# Increases the sound through the db scale
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
	# Checks if the body enter is a player
	if body.name == "player_single" or body.name == "player" or body.name == "player2":
		# Checks which level is being played
		if $"../../..".level == 1:
			pass
		elif $"../../..".level == 2:
			# Decreases the sound through the db scale
			tween.tween_property($AudioStreamPlayer3D_lava, "volume_db", -40, 2)
			# Waits three seconds
			await get_tree().create_timer(3.0).timeout
			# Stops the audio player playing
			$AudioStreamPlayer3D_lava.stop()
		elif $"../../..".level == 3:
			tween.tween_property($AudioStreamPlayer3D_underwater, "volume_db", -40, 2)
			await get_tree().create_timer(3.0).timeout
			$AudioStreamPlayer3D_underwater.stop()
		#elif $"../../..".level == 4:
			#tween.tween_property($AudioStreamPlayer3D_frozen, "volume_db", -40, 2)
			#await get_tree().create_timer(3.0).timeout
			$AudioStreamPlayer3D_frozen.stop()
