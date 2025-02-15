extends CanvasLayer

@onready var aircraft = $".."
@onready var aircraft_controls = $"../f15"
@onready var speedLabel = $HUD/SpeedCont/Speed
@onready var altitudeLabel = $HUD/Alt_Con/Alt
@onready var Left_Throttle_Tick = $HUD/HBoxContainer3/Label/Throttle_Left
@onready var HUD = $HUD
@onready var Heading_Tick = $HUD/Compass

@onready var camera = $"../CameraGimble/Camera3D"
@onready var compass_left_tick = $HUD/Compass/compass_label_l1
@onready var compass_right_tick = $HUD/Compass/compass_label_r1

@onready var compass_left_tick_2 = $HUD/Compass/compass_label_l2
@onready var compass_right_tick_2 = $HUD/Compass/compass_label_r2
@onready var borescope = $HUD/Borescrope_Cont/Boresight

@onready var label = $HUD/Compass/compass_label
@onready var headingLabel = $HUD/Heading

@onready var velocity_vector = $HUD/VelocityVector

#@onready var thrustLabel = $Control/ThrustLabel
#@onready var pitchLabel = $Control/PitchLabel
#@onready var rollLabel = $Control/RollLabel
#@onready var gForceLabel = $Control/GForceLabel
#@onready var machLabel = $Control/MachLabel
#@onready var steering = $"../AircraftModule_ControlSteering"
const tftab = ["False", "True"]
const Headings = ["N","E","S","W"]
var headingPointer = 0
var prev_heading = 0

#@onready var inputIndicatorLabel = $Control/InputIndicatorLabel

func _ready() -> void:
	var screen_center_x = HUD.get_viewport_rect().size.x / 2
	label.add_theme_color_override("font_color", Color(0, 1, 0))
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if aircraft:
		speedLabel.text = "%d" % abs(aircraft.forward_air_speed)
		altitudeLabel.text = "%d" % aircraft.global_transform.origin.y
		throttle_tick_controller()
		compass()
		update_velocity_vector()
		headingLabel.text = "Heading: %.1f°" % rad_to_deg(aircraft.rotation.y)
		#thrustLabel.text = "Thrust: %.1f%%" % (aircraft_controls.thrustSetting * 100)
		#pitchLabel.text = "Pitch: %.1f°" % rad_to_deg(aircraft.rotation.x)
		#rollLabel.text = "Roll: %.1f°" % rad_to_deg(aircraft.rotation.z)
		#gForceLabel.text = "LiftF: %.5f " % (aircraft.LiftFactor)
		#var string = tftab[int(steering.input_disabled)]
		#machLabel.text = "AOA %.1f°" % (aircraft.aoa)

func compass():
	var screen_center_x = HUD.get_viewport_rect().size.x / 2
	var offset = Heading_Tick.size.x / 2
	
	var aircraft_heading = rad_to_deg(aircraft.rotation.y)
	var aircraft_heading_360 = int(round(aircraft_heading)) % 360
	
	# Ensure heading is always positive
	if aircraft_heading_360 < 0:
		aircraft_heading_360 += 360

	# If it's the first update, center the tick
	if abs(prev_heading) == 0 && abs(aircraft_heading_360) == 0:
		Heading_Tick.position.x = screen_center_x - offset
	
	# Calculate heading difference
	var heading_difference = aircraft_heading_360 - prev_heading
	
	
	if (heading_difference == 359):
		heading_difference = 1
	elif (heading_difference == -359):
		heading_difference = -1
		
	# Reverse tick movement direction
	Heading_Tick.position.x += heading_difference*3  # Moving in opposite direction

	# Define screen boundaries
	var left_bound = (screen_center_x-offset) - 135
	var right_bound = (screen_center_x-offset) + 135

	# Wrap the tick position when it goes out of bounds
	if Heading_Tick.position.x < left_bound:
		Heading_Tick.position.x = right_bound
		headingPointer -= 1
	elif Heading_Tick.position.x > right_bound:
		Heading_Tick.position.x = left_bound
		headingPointer += 1
		
	# Keep headingPointer within valid range
	if headingPointer > 3:
		headingPointer = 0
	elif headingPointer < 0:
		headingPointer = 3

	# Update label text
	label.text = Headings[headingPointer]
	
	# Store current heading for next frame
	prev_heading = aircraft_heading_360
	
	
	# Define transparency values
	var visible_alpha = 1.0 
	var faded_alpha = 0.0 
	
	var compass_left_tick_pos = Heading_Tick.position.x - 45
	var compass_right_tick_pos = Heading_Tick.position.x + 45
	
	var compass_left_tick_pos_2 = Heading_Tick.position.x - 90
	var compass_right_tick_pos_2 = Heading_Tick.position.x + 90
	# Adjust left tick visibility
	if compass_left_tick_pos < left_bound or compass_left_tick_pos > right_bound:
		compass_left_tick.modulate.a = faded_alpha  # Fade out
	else:
		compass_left_tick.modulate.a = visible_alpha  # Fully visible

	# Adjust right tick visibility
	if compass_right_tick_pos < left_bound or compass_right_tick_pos > right_bound:
		compass_right_tick.modulate.a = faded_alpha  # Fade out
	else:
		compass_right_tick.modulate.a = visible_alpha  # Fully visible

	# Adjust left tick visibility
	if compass_left_tick_pos_2 < left_bound or compass_left_tick_pos_2 > right_bound:
		compass_left_tick_2.modulate.a = faded_alpha  # Fade out
	else:
		compass_left_tick_2.modulate.a = visible_alpha  # Fully visible

	if compass_right_tick_pos_2 < left_bound or compass_right_tick_pos_2 > right_bound:
		compass_right_tick_2.modulate.a = faded_alpha  # Fade out
	else:
		compass_right_tick_2.modulate.a = visible_alpha  # Fully visible


func update_velocity_vector():
	var velocity = aircraft.linear_velocity
	var camera_transform = camera.get_global_transform()  # Get camera transformation

	# Project velocity into screen space
	var velocity_screen_pos = camera.unproject_position(aircraft.global_position + velocity)

	# Update the velocity vector position
	velocity_vector.position = velocity_screen_pos




func throttle_tick_controller():
	var thr = aircraft_controls.thrustSetting
	

	var base_height = 0.1  
	var current_height = Left_Throttle_Tick.scale.y * base_height
	
	var new_scale_y = clamp(thr*4, 0.1, 4.0)
	var new_height = new_scale_y * base_height
	
	# Adjust position to keep the base steady
	var position_adjustment = -new_height*300
	
	
	Left_Throttle_Tick.position.y = position_adjustment

	
	# Apply the new scale
	Left_Throttle_Tick.scale.y = new_scale_y

	
	
	# Clamp final position to ensure it stays within limits
	Left_Throttle_Tick.position.y = clamp(Left_Throttle_Tick.position.y, -225, 0)

	


	
	
