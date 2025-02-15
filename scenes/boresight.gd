extends Node3D

@export var aircraft: Node3D
@export var camera: Camera3D
@export var distance: float = 100.0  # Distance where the boresight should appear

func _process(delta):
	if not aircraft or not camera:
		return

	# Get the mouse position in screen space
	var mouse_position = get_viewport().get_mouse_position()

	# Unproject to get a world position along the camera's forward direction
	var world_position = camera.project_ray_origin(mouse_position) + camera.project_ray_normal(mouse_position) * distance

	# Position the boresight at that world position
	global_transform.origin = world_position
