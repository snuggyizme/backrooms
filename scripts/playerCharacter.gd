class_name PlayerCharacter extends CharacterBody2D

# eventually will have stat mods from items and such...
# ^ why this has  consts instead of exported base values

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
const MAX_FALL_ON_WALL: float = 17.5
const MAX_FALL_ON_WALL_ENFORCEMENT_STRENGTH: float = 0.2
const WALL_JUMP_SPEED := Vector2(95.0, 125.0)
const SLIDE_DIRATION: float = 0.7
const SLIDE_MIN_SPEED: float = 50.0
const SLIDE_DRAG: float = 60.0
const SLIDE_ACCEL: float = 150.0

@export var doDebugLabel: bool

var fly: bool = false
var isSliding: bool = false
var slideTimer: float = 0.0

@onready var debugLabel: Label = $"DebugLabel"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tab"):
		print("{PlayerCharacter}: Toggle fly")
		fly = not fly

func _process(Δ: float) -> void:
	if fly:
		processFly(Δ)
	else:
		processMovement(Δ)
	
	# UNRELATED TO MOVEMENT:
	if doDebugLabel:
		debugLabel.text = str(floori(velocity.x))

func processMovement(Δ: float) -> void:
	var input: Vector2 = Input.get_vector("a", "d", "w", "s")
	var justJumped: bool = Input.is_action_just_pressed("w")
	var justSlid: bool = Input.is_action_just_pressed("s")
	
	var onFloor: bool = is_on_floor()
	var onWall: bool = is_on_wall_only()
	
	var drag: float = DRAG if ( onFloor ) else AIR_DRAG
	
	match [( input.x != null ), ( isSliding )]:
		[true, false]:
			# Horizontal control when not sliding
			velocity.x += WALK_SPEED * input.x * Δ
		[false, false]:
			# Horizontal drag when not sliding
			velocity.x = move_toward(velocity.x, 0.0, drag * Δ)
		[true, true]:
			# Horizontal control when sliding
			velocity.x += SLIDE_ACCEL * input.x * Δ
		[false, true]:
			# Horizontal drag when sliding
			velocity.x = move_toward(velocity.x, 0.0, SLIDE_DRAG * Δ)
	
	if onFloor:
		if justJumped:
			# Jump
			print("{PlayerController}: Jumped")
			var runupBonus: float = minf(abs(velocity.x) / RUNUP_MAX, 1.0) * RUNUP_STRENGTH + 1.0
			velocity.y -= JUMP_HEIGHT * runupBonus
		elif justSlid and absf(velocity.x) >= SLIDE_MIN_SPEED:
			isSliding = true
			slideTimer = SLIDE_DIRATION
	else:
		# Gravity
		velocity.y += GRAVITY * Δ
	
	if onWall:
		velocity.y = lerpf(
			velocity.y,
			minf(velocity.y, MAX_FALL_ON_WALL),
			MAX_FALL_ON_WALL_ENFORCEMENT_STRENGTH
		)
		if justJumped:
			velocity.x = WALL_JUMP_SPEED.x * get_wall_normal().x
			velocity.y = -WALL_JUMP_SPEED.y
	
	# Limiting
	var airIncrease: float = 1.0 if (onFloor) else AIR_X_MAX_SPEED_INCREASE
	var xLimit: float = MAX_WALK_SPEED * airIncrease
	var clampedX = clampf(velocity.x, -1.0 * xLimit, xLimit)
	velocity.x = move_toward(velocity.x, clampedX, OVERSPEED_DECEL * Δ)
	# ~move and slide~
	move_and_slide()

func processFly(Δ: float) -> void:
	var input: Vector2 = Input.get_vector("a", "d", "w", "s")
	
	global_position += FLY_SPEED * input * Δ
