extends StaticBody3D
signal product_check
var product_contents
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	product_check.connect($"../..".plate_check)
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("packageable"):
		product_contents = body.contents
		product_check.emit(product_contents,body,self.global_position + Vector3(0,1,0),self.rotation_degrees.y)
