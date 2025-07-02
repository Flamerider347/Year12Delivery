extends RigidBody3D
var type = "knife"
func _ready() -> void:
	$knife_animation/cut_area.connect("body_entered",$"../../../.."._on_cut_area_body_entered)
