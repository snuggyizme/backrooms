class_name C extends Node

enum Dir { LEFT, RIGHT, UP, DOWN }

const DIMENSION := Vector2i(32, 24)
const RENDER_DISTANCE_OFFSETS: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(+0, -1), Vector2i(+1, -1),
	Vector2i(-1, +0), Vector2i(+0, +0), Vector2i(+1, +0),
	Vector2i(-1, +1), Vector2i(+0, +1), Vector2i(+1, +1),
]
const ROOM_DIR: String = "res://rooms/"
