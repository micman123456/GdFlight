extends AircraftModule
class_name AircraftModule_ControlSteering

@export var ControlActive: bool = true
@export var auto_stab_frame_counter = 10
@onready var joystick = $"../HUD/HUD/MarginContainer/Joystick"
@onready var button = $"../HUD/HUD/MarginContainer/Joystick/nob"
@onready var f15 = $"../f15"

@export var over_g: float = 6.0
@export var under_g: float = -3.0

@export var g_limit: float = 9.0 
@export var elevator_mul_on : bool = true
@export var elevator_mul : float 

var input_disabled : bool = false
var input_disabled_frame_counter : int = 0

var stall : bool = false


# Axis values (-1 to 1 range)
var axis_x: float = 0.0  # Elevator (Pitch)
var axis_y: float = 0.0  # Rudder (Yaw)
var axis_z: float = 0.0  # Ailerons (Roll)
var prev_axis_z: float = 0.0

# Reference to the steering module
var steering_module = null


# Store previous joystick position
var prev_joystick: Vector2 = Vector2.ZERO


func _ready():
	ReceiveInput = true
	prev_joystick = Vector2(0,0)

func setup(aircraft_node):
	aircraft = aircraft_node
	steering_module = aircraft.find_modules_by_type("steering").pop_front()
	print("Steering module found: %s" % str(steering_module))

func receive_input(event):
	if not steering_module or not ControlActive:
		return
	if event is InputEventKey and not event.echo:
		#_handle_input()
		pass
		


func _handle_input():
	var key_axis_x = 0.0
	var key_axis_y = 0.0
	var key_axis_z = 0.0

	# Keyboard Input
	if Input.is_key_pressed(KEY_A):
		key_axis_z -= 0.05
		
	if Input.is_key_pressed(KEY_D):
		key_axis_z += 0.05
	if Input.is_action_pressed("Elevator_Max"):
		key_axis_x -= 0.05
	if Input.is_action_pressed("Elevator_Min"):
		key_axis_x += 0.05
	if Input.is_key_pressed(KEY_Q):
		key_axis_y += 0.05
	if Input.is_key_pressed(KEY_E):
		key_axis_y -= 0.05

	# Joystick Input (if no keyboard input for that axis)
	#axis_x = key_axis_x if key_axis_x != 0.0 else joystick.posVector.y
	#axis_z = key_axis_z if key_axis_z != 0.0 else joystick.posVector.x
	
	if (key_axis_x != 0.0):
		axis_x += key_axis_x
	else:
		axis_x = joystick.posVector.y * elevator_mul
	
	if (key_axis_z != 0.0):
		axis_z += key_axis_z
	else:
		axis_z = joystick.posVector.x
	if (key_axis_y != 0.0):
		axis_y += key_axis_y
	else:
		axis_y = 0.0

	# Clamp values
	
	g_limiter()
	
	if (aircraft.forward_air_speed > 200):
		axis_x = clamp(axis_x, -0.75, 0.75)
		axis_y = clamp(axis_y, -1.0, 1.0)
		axis_z = clamp(axis_z, -0.5, 0.5)
	else:
		axis_x = clamp(axis_x, -1.25, 1.25)
		axis_y = clamp(axis_y, -1.0, 1.0)
		axis_z = clamp(axis_z, -0.5, 0.5)

	# Apply input to steering module
	steering_module.set_x(axis_x)
	steering_module.set_y(axis_y)
	steering_module.set_z(axis_z)
	
	if (abs(axis_z) == 0 && abs(axis_x) == 0 && joystick.posVector == prev_joystick):
		auto_stab_frame_counter+=1
	else:
		auto_stab_frame_counter=0
	
	prev_axis_z = axis_z
	

func g_limiter():
	var g_force_x = aircraft.local_g_force
	#var g_force_z = abs(axis_z) * g_limit

	if g_force_x > g_limit:
		axis_x *= g_limit / g_force_x
	#if g_force_z > g_limit:
		#axis_z *= g_limit / g_force_z
	
func auto_stab_roll(delta: float):
	var roll = aircraft.rotation.z
	
	# Define a small tolerance to prevent unnecessary corrections
	var tolerance = deg_to_rad(2.0) 
	var roll_rate = 25
	
	if abs(roll) < tolerance:
		auto_stab_frame_counter = 0
		axis_z = 0.0  # Stop adjusting if within tolerance
	elif roll > 0:
		axis_z = lerp(axis_z, roll, delta * roll_rate)  
	else:
		axis_z = lerp(axis_z, roll, delta * roll_rate)
	steering_module.set_z(axis_z)
		
func auto_stab_pitch(delta: float):
	var pitch = aircraft.rotation.x
	var tolerance = deg_to_rad(2.0)
	var pitch_rate = 35

	if abs(pitch) < tolerance:
		auto_stab_frame_counter = 0
		axis_x = 0.0
	else:
		var pitch_target = -pitch * 2.5  # Scale appropriately for control input
		axis_x = lerp(axis_x, pitch_target, delta * pitch_rate)

	steering_module.set_x(axis_x)  # Apply to the module

		
	
	steering_module.set_x(axis_x)



func _stall_protection(delta: float):
		auto_stab_roll(delta)
		auto_stab_pitch(delta)
		f15.thrustSetting = 0.40

func is_stalled() -> bool:
	var stall_speed = 60
	var critical_aoa = deg_to_rad(15.0)  
	var ground_clearance = 10.0 

	var airspeed = aircraft.forward_air_speed
	var aoa = aircraft.rotation.x
	var altitude = aircraft.global_transform.origin.y

	return (airspeed < stall_speed and abs(aoa) > critical_aoa and altitude > ground_clearance) or (airspeed<30 and altitude > ground_clearance)

func _process(delta: float) -> void:
	stall = false # will fix later
	if stall:
		input_disabled = true
		_stall_protection(delta)
	else:
		if input_disabled:
			input_disabled_frame_counter += 1
			auto_stab_roll(delta)
			auto_stab_pitch(delta)
			if input_disabled_frame_counter > 240:
				input_disabled = false
				input_disabled_frame_counter = 0
		else:
			_handle_input()
			if auto_stab_frame_counter > 60:
				auto_stab_roll(delta)
				

		
