extends Area3D

@export var lava_ambience_sound:AudioStreamPlayer3D


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	lava_ambience_sound.play()
	


func _on_body_exited(body: Node3D) -> void:
	lava_ambience_sound.stop()


# Player enters the collision shape
# Play audio ramp up from the animation track
# when it is done, play the looping audio from auidio 3D
# Once the player then leaves the collision shape, play the ramp_up animation in reverse
# Finally, stop playing the audio once the track has finished
# Animaton Documentation types
