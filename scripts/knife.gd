extends RigidBody3D
var type = "knife"
var move = false
var objective_position = Vector3(0.38,1.01,0.65)
func _ready() -> void:
	$cut_area.connect("body_entered",$"../../.."._on_cut_area_body_entered)

func _physics_process(_delta: float) -> void:
	if move:
		rotation_degrees =Vector3(0,90,0)
		if self.position.distance_to(objective_position) > 0.1:
			self.position = self.position.lerp(objective_position, 0.2)
		else:
			self.position = objective_position
			move = false
			self.freeze = true
