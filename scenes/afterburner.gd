extends MeshInstance3D

@export var max_rad: float = 0.35
@export var min_rad: float = 0.25

@export var max_height: float = 0.75
@export var min_height: float = 0.0

@export var scaler: float = 0.05

@onready var parent = $".."
@onready var engineFireMesh: CapsuleMesh = null
@onready var material: StandardMaterial3D = null

@onready var Leftengine = $"../MeshInstance3D"
@onready var Rightengine = $"../MeshInstance3D2"

@onready var LeftengineMaterial: StandardMaterial3D = null
@onready var RightengineMaterial: StandardMaterial3D = null


var throttleSetting: float = 0

func _ready() -> void:
	if mesh is CapsuleMesh:
		engineFireMesh = mesh as CapsuleMesh
	else:
		push_error("Mesh is not a CapsuleMesh!")
	
	material = get_surface_override_material(0) as StandardMaterial3D
	if not material:
		material = StandardMaterial3D.new()
		set_surface_override_material(0, material)
		
	LeftengineMaterial = Leftengine.get_active_material(0)
	RightengineMaterial = Rightengine.get_active_material(0)
	

func _process(delta: float) -> void:
	setLocalThrottleSetting()
	updateShape()
	updateTransparency()

func setLocalThrottleSetting():
	throttleSetting = parent.thrustSetting

func updateShape():
	if engineFireMesh:
		# Set radius
		engineFireMesh.radius = clamp(max_rad * throttleSetting, min_rad, max_rad)
		
		
		# Set height
		engineFireMesh.height = clamp(max_height * throttleSetting, min_height, max_height)
	else:
		push_error("engineFireMesh is null.")



func updateTransparency():
	if material:
		var alpha_value = lerp(0.0, 0.3, throttleSetting) 
		material.albedo_color.a = alpha_value
	else:
		push_error("Material not found!")
	if LeftengineMaterial:
		var alpha_value = lerp(0.2, 1.0, throttleSetting)  
		LeftengineMaterial.albedo_color.a = alpha_value
	if RightengineMaterial:
		var alpha_value = lerp(0.2, 1.0, throttleSetting)  
		RightengineMaterial.albedo_color.a = alpha_value
