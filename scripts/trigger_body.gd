extends Area3D

@onready var timer = $Timer
@onready var audio_player = $"../AudioStreamPlayer3D_lava"

func _ready():
	self.body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)


func _on_body_entered():
	#timer.start(2.0)
	audio_player.play()


func _on_timer_timeout():
	# Plays the ambiences  when the timer completes
	audio_player.play()


#@export var lava_ambience_sound:AudioStreamPlayer3D
#
#
#func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#lava_ambience_sound.play()
	#
#
#
#func _on_body_exited(body: Node3D) -> void:
	#lava_ambience_sound.stop()
#
#
## Player enters the collision shape
## Play audio ramp up from the animation track
## when it is done, play the looping audio from auidio 3D
## Once the player then leaves the collision shape, play the ramp_up animation in reverse
## Finally, stop playing the audio once the track has finished
## Animaton Documentation types
