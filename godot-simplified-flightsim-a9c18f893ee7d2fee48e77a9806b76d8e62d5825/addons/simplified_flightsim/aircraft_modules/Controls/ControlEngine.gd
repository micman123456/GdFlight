# This script is just an example of one way to implement a control module
# the way input is handled here is by no means a requirement whatsoever
# You can (and are actually expected to) modify this or write your own module

extends AircraftModule
class_name AircraftModule_ControlEngine

@onready var f15 = $"../f15"

# Restricting engines to a tag can be used to control a group of engines only
# e.g. you can use RestrictEngineToTag=true and SearchTag="left" in the 
# inspector to control only the engines with the "left" tag (and a separate
# duplicate control for "right")
@export var RestrictEngineToTag: bool = false
@export var SearchTag: String = ""
@export var ControlActive: bool = true
@export var engine_spool_time: float = 240

@export var KeyStart: KeyScancodes = KeyScancodes.KEY_P
@export var KeyStop: KeyScancodes = KeyScancodes.KEY_O
@export var KeyUp: KeyScancodes = KeyScancodes.KEY_F
@export var KeyDown: KeyScancodes = KeyScancodes.KEY_V
@export var KeyMax: KeyScancodes = KeyScancodes.KEY_3
@export var KeyMid: KeyScancodes = KeyScancodes.KEY_2
@export var KeyMin: KeyScancodes = KeyScancodes.KEY_1

var engine_modules = []
var prev_thrust_settting = 0
var engine_spool_timer = 0


func _ready():
	ReceiveInput = true
	
func setup(aircraft_node):
	aircraft = aircraft_node
	if RestrictEngineToTag:
		engine_modules = aircraft.find_modules_by_type_and_tag("engine", SearchTag)
	else:
		engine_modules = aircraft.find_modules_by_type("engine")
	print("engines found: %s" % str(engine_modules))
	send_to_engines("engine_start")

func receive_input(event):
	if not ControlActive:
		return
	
	if (event is InputEventKey) and (not event.echo):		
		if event.pressed:
			match event.keycode:
				KeyStart:
					send_to_engines("engine_start")
				KeyStop:
					send_to_engines("engine_stop")
				KeyUp:
					send_to_engines("engine_increase_power", [0.05])
				KeyDown:
					send_to_engines("engine_increase_power", [-0.05])
				KeyMin:
					send_to_engines("engine_set_power", [0.0])
				KeyMid:
					send_to_engines("engine_set_power", [0.5])
				KeyMax:
					send_to_engines("engine_set_power", [1.0])

func send_to_engines(method_name: String, arguments: Array = []):
	for engine in engine_modules:
		engine.callv(method_name, arguments)

func set_engine_thrust(thrust_value: float):
	# Ensure thrust value is clamped between 0 and 1
	thrust_value = clamp(thrust_value, 0.0, 1.0)
	
	# Send the thrust value to all engines
	for engine in engine_modules:
		engine.call("engine_set_power", thrust_value)

func _process(delta):
	if not ControlActive:
		return
	if (prev_thrust_settting != f15.thrustSetting):
		engine_spool_timer+=1
	
	if (engine_spool_timer>=engine_spool_time):
		set_engine_thrust(f15.thrustSetting)
		prev_thrust_settting = f15.thrustSetting
		engine_spool_timer=0
	
