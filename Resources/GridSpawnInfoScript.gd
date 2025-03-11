extends Resource

class_name GridSpawnInfo

@export var spawnPoints: Array[Vector2] = [
	# 9x9 grid centered at (0,0), spaced by 105 units
	Vector2(-4, -4), Vector2(-3, -4), Vector2(-2, -4), Vector2(-1, -4), Vector2(0, -4), Vector2(1, -4), Vector2(2, -4), Vector2(3, -4), Vector2(4, -4),
	Vector2(-4, -3), Vector2(-3, -3), Vector2(-2, -3), Vector2(-1, -3), Vector2(0, -3), Vector2(1, -3), Vector2(2, -3), Vector2(3, -3), Vector2(4, -3),
	Vector2(-4, -2), Vector2(-3, -2), Vector2(-2, -2), Vector2(-1, -2), Vector2(0, -2), Vector2(1, -2), Vector2(2, -2), Vector2(3, -2), Vector2(4, -2),
	Vector2(-4, -1), Vector2(-3, -1), Vector2(-2, -1), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1), Vector2(2, -1), Vector2(3, -1), Vector2(4, -1),
	Vector2(-4,  0), Vector2(-3,  0), Vector2(-2,  0), Vector2(-1,  0), Vector2(0,  0), Vector2(1,  0), Vector2(2,  0), Vector2(3,  0), Vector2(4,  0),
	Vector2(-4,  1), Vector2(-3,  1), Vector2(-2,  1), Vector2(-1,  1), Vector2(0,  1), Vector2(1,  1), Vector2(2,  1), Vector2(3,  1), Vector2(4,  1),
	Vector2(-4,  2), Vector2(-3,  2), Vector2(-2,  2), Vector2(-1,  2), Vector2(0,  2), Vector2(1,  2), Vector2(2,  2), Vector2(3,  2), Vector2(4,  2),
	Vector2(-4,  3), Vector2(-3,  3), Vector2(-2,  3), Vector2(-1,  3), Vector2(0,  3), Vector2(1,  3), Vector2(2,  3), Vector2(3,  3), Vector2(4,  3),
	Vector2(-4,  4), Vector2(-3,  4), Vector2(-2,  4), Vector2(-1,  4), Vector2(0,  4), Vector2(1,  4), Vector2(2,  4), Vector2(3,  4), Vector2(4,  4)
]

@export var subdivision: Array[int] = [
	99, 99, 99, 99, 99, 99, 99, 99, 99,
	99, 99, 99, 99, 99, 99, 99, 99, 99,
	99, 99, 99, 99, 99, 99, 99, 99, 99,
	99, 99, 99, 99, 199, 99, 99, 99, 99,
	99, 99, 99, 199, 199, 199, 99, 99, 99,
	99, 99, 99, 99, 199, 99, 99, 99, 99,
	99, 99, 99, 99, 99, 99, 99, 99, 99,
	99, 99, 99, 99, 99, 99, 99, 99, 99,
	99, 99, 99, 99, 99, 99, 99, 99, 99
]

@export var scale: Array[int] = [
	3, 3, 3, 3, 3, 3, 3, 3, 3,
	3, 1, 1, 1, 1, 1, 1, 1, 3,
	3, 1, 1, 1, 1, 1, 1, 1, 3,
	3, 1, 1, 1, 1, 1, 1, 1, 3,
	3, 1, 1, 1, 1, 1, 1, 1, 3,
	3, 1, 1, 1, 1, 1, 1, 1, 3,
	3, 1, 1, 1, 1, 1, 1, 1, 3,
	3, 1, 1, 1, 1, 1, 1, 1, 3,
	3, 3, 3, 3, 3, 3, 3, 3, 3
]
