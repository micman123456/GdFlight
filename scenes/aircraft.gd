extends Node3D

@onready var joystick = $Aircraft/HUD/HUD/MarginContainer/Joystick
@onready var staticBodyAircraft = $Aircraft
@onready var AircraftModel = $Aircraft/f15
@onready var ExplosionAnimation = $Aircraft/Explosion/AnimationPlayer
@onready var Explosion = $Aircraft/Explosion
@onready var Camera = $Aircraft/CameraGimble/Camera3D
@onready var HUD = $Aircraft/HUD
@onready var AnimPlayer = $Aircraft/AnimationPlayer
@onready var Audio = $Aircraft/F15EngineLeft


var crashed : bool = false

var resetPosition: Vector3
var resetVelocity: Vector3
var resetRotation: Quaternion

var is_crashed : bool = false
var CrashTimer = 0


func _ready() -> void:
	if (staticBodyAircraft):
		resetPosition = staticBodyAircraft.global_position
		resetVelocity = Vector3(100,0,0)
		resetRotation = staticBodyAircraft.global_transform.basis.get_rotation_quaternion()
		
		staticBodyAircraft.connect("crashed", Callable(self, "_on_crash"))
		

func _process(delta: float) -> void:
	var direction = joystick.posVector
	_reset_caller()
	
	if(is_crashed):
		if(CrashTimer>300):
			_reset()
		else:
			CrashTimer+=1

func _reset_caller():
		if Input.is_key_pressed(KEY_R):
			_reset()
		if Input.is_key_pressed(KEY_J):
			AnimPlayer.play("crash_anim")	
			
func _reset():
			staticBodyAircraft.no_physics_mode = false
			staticBodyAircraft.global_position = resetPosition
			staticBodyAircraft.linear_velocity = resetVelocity
			staticBodyAircraft.global_transform.basis = Basis(resetRotation)
			staticBodyAircraft.angular_velocity = Vector3.ZERO
			is_crashed = false
			CrashTimer = 0
			#AircraftModel.visible = true
			HUD.visible = true
			Camera.fov = 70
			Camera.unfreeze()
			#Audio.play_audio()
			

func _on_crash(impact_velocity: Vector3):
	if not is_crashed:
		Camera.fov = 105
		AnimPlayer.play("crash_anim")
		HUD.visible = false
		is_crashed = true
		
	staticBodyAircraft.linear_velocity = Vector3.ZERO
	staticBodyAircraft.angular_velocity = Vector3.ZERO
		
		
	
