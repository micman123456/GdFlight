@tool
extends Node3D




# Get waterplane and preset grid spawn info
var OceanTile = preload("res://scenes/mesh_instance_3d.tscn")
var spawnPoint = preload("res://Resources/GridSpawnInfo.tres")
@onready var player = $"../AircraftController/Aircraft"




# Creates tile grid for infinite ocean
func createOceanTiles():
	for i in range(spawnPoint.spawnPoints.size()):  # Loop through all 49 tiles
		var spawnLocation = spawnPoint.spawnPoints[i]
		var tileSubdivision = spawnPoint.subdivision[i]
		var tileScale = spawnPoint.scale[i]
		var instance = OceanTile.instantiate()

		add_child(instance)

		# Set position & scale for 105x105 tiles
		instance.position = Vector3(spawnLocation.x, 0.0, spawnLocation.y) * 105.0
		instance.mesh.set_subdivide_width(tileSubdivision)
		instance.mesh.set_subdivide_depth(tileSubdivision)

		# Scale to 105x105
		instance.set_scale(Vector3(tileScale * 100.0, 1.0, tileScale * 100.0))



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createOceanTiles()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("ocean_pos", self.position)
	if player:
		global_position.x = player.global_position.x
		global_position.z = player.global_position.z
		
