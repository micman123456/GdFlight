extends Node3D
var resetting: bool = false
var moving: bool = false
var velocity = 0

@export var acceleration_threshold: float = 15
@export var response_strength: float = 0.1
@export var max_zoom = 1.2
@export var min_zoom = 1.0
@export_range(0.05, 1.0) var zoom_speed = 0.01

@export var zoom:float = 1.0


@onready var aircraft = $".."  
@onready var control = $"../AircraftModule_ControlSteering"


func _process(delta: float) -> void:
	if resetting:
		resetCameraPosition(delta)
	elif not moving:
		
		var pitch_movement = control.axis_x
		var yaw_movement = control.axis_y
		var current_forward_velocity = aircraft.forward_air_speed
		var acceleration = (current_forward_velocity - velocity) / delta
		velocity = current_forward_velocity
		
		
		var rotationVector = Vector2(yaw_movement,pitch_movement)
		zoom_with_speed(acceleration,delta)
		rotate_from_control_inputs(rotationVector*0.005,delta)
		scale = lerp(scale, Vector3.ONE * zoom, zoom_speed)

func _input(event: InputEvent) -> void:

	
	if event is InputEventMouseMotion and Input.is_action_pressed("move_camera"):
		rotate_from_vector(event.relative * 0.005)
		resetting = false
		moving = true
	elif event is InputEventKey and event.is_action_released("move_camera"):
		resetting = true
		moving = false
	

func rotate_from_vector(v: Vector2):
	if v.length() == 0:
		return
	rotation.y -= v.x
	rotation.x -= v.y
	#rotation.x = clamp(rotation.x, -0.5, 0.5)
	
func rotate_from_control_inputs(v: Vector2, delta: float):
	var threshold = 0.01
	
	rotation.y -= v.x
	rotation.x -= v.y
	
	
	rotation.x = clamp(rotation.x, -0.15, 0.15)
	rotation.y = clamp(rotation.y, -0.15, 0.15)
	
	if (abs(v.y) < threshold):
		rotation.x = lerp(rotation.x,0.0,delta*10)
	if (abs(v.x) < threshold):
		rotation.y = lerp(rotation.y,0.0,delta*10)

func resetCameraPosition(delta: float) -> void:
	# Smoothly reset rotation.x towards 0
	if rotation.x != 0:
		if rotation.x > 0:
			rotation.x = max(rotation.x - delta * 2.0, 0) # Decrease x rotation smoothly
		else:
			rotation.x = min(rotation.x + delta * 2.0, 0) # Increase x rotation smoothly
	

	# Smoothly reset rotation.y towards 0
	if rotation.y != 0:
		if rotation.y > 0:
			rotation.y = max(rotation.y - delta * 2.0, 0) # Decrease y rotation smoothly
		else:
			rotation.y = min(rotation.y + delta * 2.0, 0) # Increase y rotation smoothly
	
	if (rotation.y == 0 && rotation.x == 0):
		resetting = false

func zoom_with_speed(acc:float, delta:float):
	if (acc>acceleration_threshold):
		zoom += zoom_speed
	else:
		zoom -= zoom_speed
	zoom = clamp(zoom, min_zoom, max_zoom)
		
	
	
	
