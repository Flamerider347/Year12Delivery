extends StaticBody3D

@export var audio_stream:AudioStreamPlayer


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	audio_stream.play()
	
