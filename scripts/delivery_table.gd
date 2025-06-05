extends StaticBody3D
signal product_check
var product_contents
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	product_check.connect($"../..".plate_check)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("packageable"):
		product_contents = body.contents
		product_check.emit(product_contents,body)
