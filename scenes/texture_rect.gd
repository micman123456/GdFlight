extends TextureRect

@export var aircraft: Node3D
@export var camera: Camera3D

func _process(delta):
	if not aircraft or not camera:
		return

	# Project boresight world position to screen space

	# Set UI position (adjust for center alignment)
	position.x = position.x
	position.y = position.y + 10
	
