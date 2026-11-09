class_name PlayerCharacter extends CharacterBody2D

# eventually will have stat mods from items and such...
# ^ why this has C. consts instead of exported base values

@export var doDebugLabel: bool

var fly: bool = false

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
	var input: Vector2 = Input.get_vector.callv(C.INPUTS)
	var justJumped: bool = Input.is_action_just_pressed("w")
	
	var onFloor: bool = is_on_floor()
	var _onWall: bool = is_on_wall()
	
	var drag: float = C.DRAG if ( onFloor ) else C.AIR_DRAG
	
	if input.x != 0.0:
		# Horizontal control
		velocity.x += C.WALK_SPEED * input.x * Δ
	else:
		# Horizontal drag
		velocity.x = move_toward(velocity.x, 0.0, drag * Δ)
	
	if onFloor:
		if justJumped:
			# Jump
			print("{PlayerController}: Jumped")
			var runupBonus: float = minf(abs(velocity.x) / C.RUNUP_MAX, 1.0) * C.RUNUP_STRENGTH + 1.0
			velocity.y -= C.JUMP_HEIGHT * runupBonus
	else:
		# Gravity
		velocity.y += C.GRAVITY * Δ
	
	# Limiting
	var airIncrease: float = 1.0 if (onFloor) else C.AIR_X_MAX_SPEED_INCREASE
	var xLimit: float = C.MAX_WALK_SPEED * airIncrease
	var clampedX = clampf(velocity.x, -1.0 * xLimit, xLimit)
	velocity.x = move_toward(velocity.x, clampedX, C.OVERSPEED_DECEL * Δ)
	# ~move and slide~
	move_and_slide()

func processFly(Δ: float) -> void:
	var input: Vector2 = Input.get_vector.callv(C.INPUTS)
	
	global_position += C.FLY_SPEED * input * Δ
