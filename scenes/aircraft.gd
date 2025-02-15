extends Node3D

@onready var joystick = $Aircraft/HUD/HUD/MarginContainer/Joystick

func _process(delta: float) -> void:
	var direction = joystick.posVector
