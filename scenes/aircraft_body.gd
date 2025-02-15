extends RigidBody3D

var Velocity: Vector3
var LocalVelocity: Vector3
var lastVelocity: Vector3
var LocalGForce: Vector3 
var LocalAngularVelocity: Vector3  
var AngleOfAttackPitch: float
var AngleOfAttackYaw: float

@export var LiftCurve: Curve
@export var LiftPower: float
@export var flaps_lift_power: float
@export var flaps_aoa_bias: int
@export var drag_coeff : float
@export var afterburner: bool = true

@export var YawPower : float
@export var LiftDragParam : float
@export var YawDragParam : float

var i = 0

@onready var aircraft = $f15
var MAXTHRUST = 211400

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	calculate_state(delta)
	calculate_angle_of_attack()
	calculate_g_force(delta)
	update_thrust()
	update_drag()
	update_lift()
	
	if (i%100 == 0):
		print("Forward velocity : ", LocalVelocity.z)
		print("Upwards velocity : ", LocalVelocity.y)
		
		i=0
	
	i += 1


func calculate_state(delta: float):
	var inv_rotation = global_transform.basis.orthonormalized().inverse()
	Velocity = linear_velocity
	LocalVelocity = inv_rotation * Velocity
	
	LocalAngularVelocity = inv_rotation * angular_velocity  
	
	
func calculate_angle_of_attack():
	
	if LocalVelocity.length_squared() < 0.1:
		AngleOfAttackPitch = 0
		AngleOfAttackYaw = 0
		#print("AOA Pitch (degrees):", round(AngleOfAttackPitch))
		#print("AOA Yaw (degrees):", round(AngleOfAttackYaw))
		return  # Exit early if velocity is too low
	
	var epsilon = 0.01  
	
	# Ensure AOA is calculated when moving forward
	var clamped_velocity_z = max(abs(LocalVelocity.z), epsilon)  
	var clamped_velocity_y = -max(abs(LocalVelocity.y), epsilon)
	var clamped_velocity_x = -max(abs(LocalVelocity.x), epsilon)

	# Compute the angle of attack correctly
	AngleOfAttackPitch = atan2(clamped_velocity_y, clamped_velocity_z)
	AngleOfAttackYaw = atan2(clamped_velocity_x,clamped_velocity_z)

	# Convert to degrees
	AngleOfAttackPitch = rad_to_deg(AngleOfAttackPitch)
	AngleOfAttackYaw = rad_to_deg(AngleOfAttackYaw)

	#print("AOA Pitch (degrees):", round(AngleOfAttackPitch))
	#print("AOA Yaw (degrees):", round(AngleOfAttackYaw))



func calculate_g_force(delta: float):
	var inv_rotation = global_transform.basis.orthonormalized().inverse()
	var acceleration = (Velocity - lastVelocity) / delta
	LocalGForce = inv_rotation * acceleration  # LocalGForce is now a Vector3
	lastVelocity = Velocity



func update_thrust():
	var thrust = MAXTHRUST if afterburner else 129800
	var thrust_force = aircraft.thrustSetting * thrust * Vector3.FORWARD
	var world_force = global_transform.basis * thrust_force
	apply_central_force(world_force)
	
func update_drag():
	var lv = LocalVelocity
	var lv2 = lv * lv
	var drag = drag_coeff * lv2 * -lv.normalized()
	apply_central_force(drag)

func update_lift():
	# Get lift coefficient from curve
	var aoa_clamped = clamp(AngleOfAttackPitch, -90, 90)
	var curve_x = (aoa_clamped + 90.0) / 180.0
	var lift_coefficient = LiftCurve.sample(curve_x)
	print(lift_coefficient)
	
	var lift_velocity = LocalVelocity.project(Vector3.RIGHT)

	var v2 = lift_velocity.length_squared()
	var lift_force = v2 * lift_coefficient * LiftPower
	var lift_direction = Vector3.UP
	
	apply_central_force(global_transform.basis * lift_force * lift_direction)
