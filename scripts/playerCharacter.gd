class_name PlayerCharacter extends CharacterBody2D

# eventually will have stat mods from items and such...

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
const SLIDE_DURATION: float = 1.1
const SLIDE_MIN_SPEED: float = 50.0
const SLIDE_DRAG: float = 60.0
const SLIDE_ACCEL: float = 25.0
const SLIDE_X_MAX_SPEED_INCREASE: float = 1.3
const SLIDE_BOOST: float = 25.0
const SLIDE_TRANS := Tween.TransitionType.TRANS_CIRC
const SLIDE_EASE := Tween.EaseType.EASE_OUT
const SLIDE_TWEEN_TIME: float = 0.6
const EXTRA_SLIDE_FRICTION: float = 5.0
const EXTRA_SLIDE_FRICTION_TIME: float = 0.7
const FASTFALL_SPEED: float = 2.6
const SLIDE_DOWNWARD_PUSH: float = 15.5

@export var debug: bool

var fly: bool = false
var isSliding: bool = false
var slideTimer: float = 0.0
var slideBoost: float = 0.0
var slideTween: Tween

@onready var speedLabel: Label = $"DebugInfo/SpeedLabel"
@onready var slidingIndicator: Sprite2D = $"DebugInfo/SlidingIndicator"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tab"):
		print("{PlayerCharacter}: Toggle fly")
		fly = not fly

func _physics_process(Δ: float) -> void:
	if fly:
		processFly(Δ)
	else:
		processMovement(Δ)
	
	# UNRELATED TO MOVEMENT:
	if debug:
		speedLabel.text = str(floori(velocity.x))
		slidingIndicator.visible = ( isSliding )

func processMovement(Δ: float) -> void:
	var input: Vector2 = Input.get_vector("a", "d", "w", "s")
	var justJumped: bool = Input.is_action_just_pressed("w")
	var justSlid: bool = Input.is_action_just_pressed("s")
	
	var onFloor: bool = is_on_floor()
	var onWall: bool = is_on_wall_only()
	
	var drag: float = DRAG if ( onFloor ) else AIR_DRAG
	
	if isSliding:
		slideTimer -= Δ
		#velocity.y = SLIDE_DOWNWARD_PUSH
		
		if slideTimer <= EXTRA_SLIDE_FRICTION_TIME:
			var extraFriction: float = (
				EXTRA_SLIDE_FRICTION * (slideTimer / EXTRA_SLIDE_FRICTION_TIME)
			)
			velocity.x = move_toward(velocity.x, 0.0, extraFriction)
	
	if ( slideTimer <= 0.0 ) or !( input.y >= 0 ) or !( onFloor ):
		isSliding = false
	
	match [ ( input.x != 0.0 ), ( isSliding ) ]:
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
		velocity.x = move_toward(velocity.x, 0.0, -(slideBoost))
		if justJumped:
			# Jump
			print("{PlayerController}: Jumped")
			var runupBonus: float = minf(abs(velocity.x) / RUNUP_MAX, 1.0) * RUNUP_STRENGTH + 1.0
			velocity.y -= JUMP_HEIGHT * runupBonus
		elif (
			( justSlid ) and
			( absf(velocity.x) >= SLIDE_MIN_SPEED ) and
			( not isSliding )
		):
			# Slide
			print("{PlayerController}: Started slide")
			isSliding = true
			slideTimer = SLIDE_DURATION
			slideBoost = 25.0
			
			if slideTween != null:
				slideTween.kill()
			slideTween = create_tween()
			slideTween.set_trans(SLIDE_TRANS).set_ease(SLIDE_EASE)
			slideTween.tween_property(self, "slideBoost", 0.0, SLIDE_TWEEN_TIME)
	else:
		# Gravity
		var mult: float = FASTFALL_SPEED if ( input.y > 0.0 ) else 1.0
		velocity.y += GRAVITY * mult * Δ
	
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
	var airIncrease: float = 1.0
	if not onFloor:
		airIncrease = AIR_X_MAX_SPEED_INCREASE
	elif isSliding:
		airIncrease = SLIDE_X_MAX_SPEED_INCREASE
	var xLimit: float = MAX_WALK_SPEED * airIncrease
	var clampedX = clampf(velocity.x, -1.0 * xLimit, xLimit)
	velocity.x = move_toward(velocity.x, clampedX, OVERSPEED_DECEL * Δ)
	# ~move and slide~
	move_and_slide()

func processFly(Δ: float) -> void:
	var input: Vector2 = Input.get_vector("a", "d", "w", "s")
	
	global_position += FLY_SPEED * input * Δ
