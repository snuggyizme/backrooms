class_name C extends Node

enum Dir { LEFT, RIGHT, UP, DOWN }
enum Err {
	ROOM_NO_FITTING_CONNECTIONS,
}

const DIMENSION := Vector2i(32, 24)
const TILE_DIMENSION := Vector2i.ONE * 16
const RENDER_DISTANCE_OFFSETS: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(+0, -1), Vector2i(+1, -1),
	Vector2i(-1, +0), Vector2i(+0, +0), Vector2i(+1, +0),
	Vector2i(-1, +1), Vector2i(+0, +1), Vector2i(+1, +1),
]
const ROOM_DIR: String = "res://rooms/"
const INPUTS: Array[String] = ["a", "d", "w", "s"]
const WALK_SPEED: float = 255.0
const DRAG: float = 250.0
const AIR_DRAG: float = 100.0
const RUNUP_MAX: float = 50.0
const RUNUP_STRENGTH: float = 0.5
const MAX_WALK_SPEED: float = 100.0
const JUMP_HEIGHT: float = 85.0
const GRAVITY: float = 170.0
const AIR_X_MAX_SPEED_INCREASE: float = 1.25
const OVERSPEED_DECEL: float = 300.0
const FLY_SPEED: float = 600.0
const ERR_ROOM_SCENE: PackedScene = preload("res://rooms/_errorRoom.tscn")
