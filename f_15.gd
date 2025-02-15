extends Node3D

# Ranges in Degrees 
@export_range(-30, 30, 0.1) var rudder_range: float
@export_range(75, 105, 0.1) var flaps_range: float
@export_range(0,1,0.1) var thrustSetting: float = 1

@onready var aircraft = $".."
@onready var aircraftBaseLiftFactor = aircraft.LiftFactor
@onready var aircraftBaseDragFactor = aircraft.DragFactor

var flap_step: int = 10

var elevator_min = 75
var elevator_max = 105
var elevator_center = 90
var elevator_range: int = 15

var ailerons_min = 75
var ailerons_max = 105
var ailerons_center = 90
var ailerons_range: int = 15

@export var LiftFactorFlap1: float = 0.0005
@export var LiftFactorFlap2: float = 0.001

@export var DragFactorFlap1: float = 0.005
@export var DragFactorFlap2: float = 0.01

# Flap Settings
@export_range(0, 2) var flaps_setting: int

# F-15 and Components
@onready var LeftElevator = $LeftElevator
@onready var RightElevator = $RightElevator

@onready var LeftFlap = $LeftFlap
@onready var RightFlap = $RightFlap

@onready var LeftRudder = $LeftRudder
@onready var RightRudder = $RightRudder

@onready var LeftAileron = $LeftAileron
@onready var RightAileron = $RightAileron


# Default Pos for Components
@onready var DefaultFlapPosition: float = LeftFlap.rotation.x

@onready var Default_Left_El_Position: float = LeftElevator.rotation.x
@onready var Default_Right_El_Position: float = RightElevator.rotation.x

# Moving states for Components
var FlapsMoving: bool = false
var LeftElevatorMoving: bool = false
var RightElevatorMoving: bool = false
var RudderMoving: bool = false


# Angle states and speed for Components
var current_flap_angle: float = 90  # Current angle of the flaps
var target_flap_angle: float = 90  # Target angle for the flaps
var flap_speed: float = 5.0  # Speed of the flap movement

var l_elevator_current_angle: float = 90  # Current angle of the left elevator
var r_elevator_current_angle: float = 90  # Current angle of the right elevator
var target_l_elevator: float = 90  # Target angle for the left elevator
var target_r_elevator: float = 90  # Target angle for the right elevator
var l_elevator_speed: float = 30.0  # Speed of the left elevator
var r_elevator_speed: float = 30.0  # Speed of the right elevator

var rudder_current_angle: float = 0  # Current angle of the rudder
var target_rudder_angle: float = 0  # Target angle for the rudder
var rudder_speed: float = 30.0  # Speed of the rudder movement

var L_ailerons_current_angle: float = 90  # Current angle of the ailerons
var L_target_ailerons_angle: float = 0  # Target angle for the ailerons
var L_ailerons_speed: float = 30.0  # Speed of the ailerons movement
var L_AileronsMoving: bool = false

var R_ailerons_current_angle: float = 90  # Current angle of the ailerons
var R_target_ailerons_angle: float = 0  # Target angle for the ailerons
var R_ailerons_speed: float = 30.0  # Speed of the ailerons movement
var R_AileronsMoving: bool = false


func _ready():
	var steering_module = get_parent().find_child("AircraftModule_Steering")
	if steering_module:
		steering_module.connect("control_surface_update", Callable(self, "_on_control_surface_update"))


func _on_control_surface_update(axis: String, value: float):
	if axis == "elevator":
		var input = elevator_center + elevator_range*value
		setElevatorPosition(input) 
	elif axis == "aileron":
		Roll(value)
	elif axis == "rudder":
		setRudderPosition(remap(value, -1, 1, -30, 30)) 



func _process(delta: float) -> void:
	
	# Elevator logic
	if Input.is_action_just_pressed("toggle_flaps"):
		ToggleFlaps()
		print('Flaps Set to ' + str(flaps_setting))
	
	if Input.is_action_pressed("Throttle_Up"):
		UpdateThrottlePosition(0.025)

	if Input.is_action_pressed("Throttle_Down"):
		UpdateThrottlePosition(-0.05)


	# Update movements
	if FlapsMoving:
		MoveFlaps(delta)
	if LeftElevatorMoving && RightElevatorMoving:
		MoveLeftElevator(delta)
		MoveRightElevator(delta)
	else:
		setElevatorPosition(90)
	if RudderMoving:
		MoveRudder(delta)
	else:
		setRudderPosition(0)
	if L_AileronsMoving && R_AileronsMoving:
		MoveLeftAileron(delta)
		MoveRightAileron(delta)
	else:
		resetRoll()
		


func resetRoll():
	# Neutralize the ailerons
	L_target_ailerons_angle = 90
	R_target_ailerons_angle = 90
	L_AileronsMoving = true
	R_AileronsMoving = true

# Flap Functions #
func ToggleFlaps():
	# Toggle between the two flap settings and set the target angle
	
	flaps_setting+=1
	
	if (flaps_setting == 1):
		aircraft.LiftFactor = aircraftBaseLiftFactor + LiftFactorFlap1
		aircraft.DragFactor.z = aircraftBaseDragFactor.z + DragFactorFlap1
	elif (flaps_setting ==2):
		aircraft.LiftFactor = aircraftBaseLiftFactor + LiftFactorFlap2
		aircraft.DragFactor.z = aircraftBaseDragFactor.z + DragFactorFlap2
	elif (flaps_setting>2):
		flaps_setting=0
		aircraft.LiftFactor = aircraftBaseLiftFactor
		aircraft.DragFactor.z = aircraftBaseDragFactor.z
		
	target_flap_angle = flaps_range_min() + flaps_setting*flap_step
	# Start moving flaps
	
	FlapsMoving = true

func MoveFlaps(delta: float):
	# Smoothly interpolate the current flap angle toward the target angle
	current_flap_angle = lerp(current_flap_angle, target_flap_angle, flap_speed * delta)
	
	# Apply the rotation to the flaps
	LeftFlap.rotation_degrees.x = current_flap_angle
	RightFlap.rotation_degrees.x = current_flap_angle
		
	# Check if the flaps have reached the target position
	if abs(current_flap_angle - target_flap_angle) < 0.1:
		current_flap_angle = target_flap_angle
		FlapsMoving = false

func flaps_range_min() -> float:
	return 90

func flaps_range_max() -> float:
	return 105
	
	
# Elevator Functions 

func setElevatorPosition(input: float):
	target_l_elevator = input
	target_r_elevator = input
	LeftElevatorMoving = true
	RightElevatorMoving = true
	
	

func MoveLeftElevator(delta: float):
	# Smoothly interpolate the current left elevator angle toward the target angle
	l_elevator_current_angle = lerp(l_elevator_current_angle, target_l_elevator, l_elevator_speed * delta)

	# Apply the rotation to the left elevator
	LeftElevator.rotation_degrees.x = l_elevator_current_angle

	# Check if the left elevator has reached the target position
	if abs(l_elevator_current_angle - target_l_elevator) < 0.1:
		l_elevator_current_angle = target_l_elevator
		LeftElevatorMoving = false

func MoveRightElevator(delta: float):
	# Smoothly interpolate the current right elevator angle toward the target angle
	r_elevator_current_angle = lerp(r_elevator_current_angle, target_r_elevator, r_elevator_speed * delta)

	# Apply the rotation to the right elevator
	RightElevator.rotation_degrees.x = r_elevator_current_angle

	# Check if the right elevator has reached the target position
	if abs(r_elevator_current_angle - target_r_elevator) < 0.1:
		r_elevator_current_angle = target_r_elevator
		RightElevatorMoving = false

func MoveBothElevators(delta: float):
	# Move both elevators simultaneously
	MoveLeftElevator(delta)
	MoveRightElevator(delta)
	

# Rudder functions

func setRudderPosition(input: float):
	target_rudder_angle = input
	RudderMoving = true

func MoveRudder(delta: float):
	# Smoothly interpolate the current rudder angle toward the target angle
	rudder_current_angle = lerp(rudder_current_angle, target_rudder_angle, rudder_speed * delta)

	# Apply the rotation to the rudder
	LeftRudder.rotation_degrees.y = rudder_current_angle
	RightRudder.rotation_degrees.y = rudder_current_angle

	# Check if the rudder has reached the target position
	if abs(rudder_current_angle - target_rudder_angle) < 0.1:
		rudder_current_angle = target_rudder_angle
		RudderMoving = false

# Aileron Functions

func Roll(input: float):
	
	L_target_ailerons_angle = ailerons_center + ailerons_range*input
	R_target_ailerons_angle = ailerons_center - ailerons_range*input
	L_AileronsMoving = true
	R_AileronsMoving = true

func MoveLeftAileron(delta: float):
	# Smoothly interpolate the current left elevator angle toward the target angle
	L_ailerons_current_angle = lerp(L_ailerons_current_angle, L_target_ailerons_angle, L_ailerons_speed * delta)

	# Apply the rotation to the left elevator
	LeftAileron.rotation_degrees.x = L_ailerons_current_angle

	# Check if the left elevator has reached the target position
	if abs(L_ailerons_current_angle - L_target_ailerons_angle) < 0.1:
		L_ailerons_current_angle = L_target_ailerons_angle
		L_AileronsMoving = false

func MoveRightAileron(delta: float):
	# Smoothly interpolate the current left elevator angle toward the target angle
	R_ailerons_current_angle = lerp(R_ailerons_current_angle, R_target_ailerons_angle, R_ailerons_speed * delta)
	

	# Apply the rotation to the left elevator
	RightAileron.rotation_degrees.x = R_ailerons_current_angle

	# Check if the left elevator has reached the target position
	if abs(R_ailerons_current_angle - R_target_ailerons_angle) < 0.1:
		R_ailerons_current_angle = R_target_ailerons_angle
		R_AileronsMoving = false

func UpdateThrottlePosition(input : float):
	thrustSetting+=input
	thrustSetting = clamp(thrustSetting, 0.1, 1)
	
	
