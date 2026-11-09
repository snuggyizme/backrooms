class_name WorldController extends Node

@export var player: PlayerCharacter

var worldSeed: int
var rng: RandomNumberGenerator
var loadedRooms: Dictionary[Vector2i, Room]
var roomCache: Dictionary[Vector4i, Array] # Dictionary[Vector4i, Array[PackedScene]]

# ------------------------- #
# Notes on Vector4i keying: #
# ------------------------- #
# Vector4i.x: Left          #
# Vector4i.y: Right         #
# Vector4i.z: Top           #
# Vector4i.w: Bottom        #
# ------------------------- #
# See _connections.txt for  #
# information about what    #
# the value of x/y/z/w      #
# represents :3             #
# ------------------------- #


func _ready() -> void:
	cacheRoomConnections(true, false, true)
	randomizeSeed()

func _process(_Δ: float) -> void:
	# Get player position
	var playerPos: Vector2 = player.global_position
	var playerRoomPos := Vector2i(
		floori(playerPos.x / (C.DIMENSION.x * C.TILE_DIMENSION.x)),
		floori(playerPos.y / (C.DIMENSION.y * C.TILE_DIMENSION.y)),
	)
	
	# Get rooms around player
	var roomCoordsWanted: Array[Vector2i] = []
	for offset: Vector2i in C.RENDER_DISTANCE_OFFSETS:
		roomCoordsWanted.append(playerRoomPos + offset)
	
	# Get rooms we need ( fuck Godot's wuss typing, I have to do Array here )
	var roomCoordsNeeded: Array = roomCoordsWanted.filter(
		func(x: Vector2i):
			return ( x not in loadedRooms.keys() )
	)
	
	# Get rooms we don't need anymore ( hnng )
	var roomCoordsToDump: Array = loadedRooms.keys().filter(
		func(x: Vector2i):
			return ( x not in roomCoordsWanted )
	)
	
	# Remove old rooms
	for coordToDump in roomCoordsToDump:
		loadedRooms[coordToDump].queue_free()
		loadedRooms.erase(coordToDump)
	
	# Make new rooms
	for roomCoord: Vector2i in roomCoordsNeeded:
		var chunkRng := RandomNumberGenerator.new()
		chunkRng.seed = hash(worldSeed * roomCoord)
		
		var left: Room = loadedRooms.get(roomCoord + Vector2i.UP)
		var right: Room = loadedRooms.get(roomCoord + Vector2i.RIGHT)
		var above: Room = loadedRooms.get(roomCoord + Vector2i.DOWN)
		var below: Room = loadedRooms.get(roomCoord + Vector2i.LEFT)
		
		var validConnections: Array[Vector4i] = getValidConnections(
			left, right, above, below
		)
		
		if validConnections.size() == 0:
			var errorRoom: ErrorRoom = C.ERR_ROOM_SCENE.instantiate()
			
			var vec := Vector4i(NAN, NAN, NAN, NAN)
			
			if left != null:
				vec.x = left.connections.y
			if right != null:
				vec.y = right.connections.x
			if above != null:
				vec.z = above.connections.w
			if below != null:
				vec.w = below.connections.z
				
			errorRoom.setError(vec)
			
			errorRoom.global_position = roomCoord * C.DIMENSION * C.TILE_DIMENSION
			add_child(errorRoom)
			loadedRooms[roomCoord] = errorRoom
			continue
		
		var connections: Vector4i = validConnections[chunkRng.randi() % validConnections.size()]
		var roomScene: PackedScene = roomCache[connections][chunkRng.randi() % roomCache[connections].size()]
		var room: Room = roomScene.instantiate()
		room.global_position = roomCoord * C.DIMENSION * C.TILE_DIMENSION
		add_child(room)
		loadedRooms[roomCoord] = room

func randomizeSeed() -> void:
	randomize()
	worldSeed = hash(Time.get_ticks_usec() + randi())
	rng = RandomNumberGenerator.new()
	rng.seed = worldSeed

func cacheRoomConnections(useFileName: bool = false, addHidden: bool = false, debugPrint: bool = false) -> void:
	var dir := DirAccess.open(C.ROOM_DIR)
	dir.list_dir_begin()
	
	for path: String in dir.get_files():
		if path.get_extension() == "remap":
			path = path.replace(".remap", "")
		
		if path.begins_with("_") and not addHidden:
			continue
		
		# Get scene
		var packed: PackedScene = load(C.ROOM_DIR + path)
		
		# Get connections
		var connections: Vector4i
		if useFileName:
			var s: String = path.substr(0, 4)
			connections = Vector4i( # Surely a better way? This is ugly.
				s[0].to_int(),
				s[1].to_int(),
				s[2].to_int(),
				s[3].to_int(),
			)
		else:
			# Get data and free ( hate this typing thing )
			var temp: Room = packed.instantiate()
			
			if debugPrint:
				print("{WorldController}: Instantiated room ", temp.name)
			
			connections = temp.connections
			temp.free()
		
		# Add to dictionary
		if not roomCache.has(connections):
			roomCache[connections] = [] as Array[PackedScene]
		roomCache[connections].append(packed)
		
	dir.list_dir_end()

func getValidConnections(
	above: Room = null,
	right: Room = null,
	below: Room = null,
	left: Room = null,
) -> Array[Vector4i]:
	var validConnections: Array[Vector4i] = roomCache.keys()
	
	if above != null:
		validConnections = validConnections.filter(
			func(x: Vector4i): return x.z == above.connections.w
		)
	
	if right != null:
		validConnections = validConnections.filter(
			func(x: Vector4i): return x.y == right.connections.x
		)
	
	if below != null:
		validConnections = validConnections.filter(
			func(x: Vector4i): return x.w == below.connections.z
		)

	if left != null:
		validConnections = validConnections.filter(
			func(x: Vector4i): return x.x == left.connections.y
		)
	
	return validConnections
