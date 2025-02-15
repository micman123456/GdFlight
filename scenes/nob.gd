extends Sprite2D

var pressing : bool = false
var freeze : bool = false
@onready var parent = $".."

@export var max_length = 400
@export var deadzone = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_length *= parent.scale.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_C):
		freeze = true
	else:
		freeze = false
	
	if pressing and not freeze:
		if get_global_mouse_position().distance_to(parent.global_position) <= max_length:
			global_position = get_global_mouse_position()
		else:
			var angle = parent.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = parent.global_position.x + cos(angle) * max_length
			global_position.y = parent.global_position.y + sin(angle) * max_length
		calculateVector()
	elif not freeze:
		global_position = lerp(global_position, parent.global_position, delta * 10)
		parent.posVector = Vector2(0, 0)

func calculateVector():
	if abs((global_position.x - parent.global_position.x)) >= deadzone:
		parent.posVector.x = (global_position.x - parent.global_position.x) / max_length
	if abs((global_position.y - parent.global_position.y)) >= deadzone:
		parent.posVector.y = (global_position.y - parent.global_position.y) / max_length

func _on_button_button_down() -> void:
	pressing = true

func _on_button_button_up() -> void:
	pressing = false
