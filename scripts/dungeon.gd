extends Node2D

@export var max_dungeon_size: Vector2i = Vector2(10, 10)

@onready var dungeon_tiles: TileMapLayer = $"Dungeon_TileMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_dungeon_layer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("generate_layer"):
		generate_dungeon_layer()

func generate_dungeon_layer():
	dungeon_tiles.clear()
	for i in range(10): # spawn 5 rooms
		for j in range(3): # retry until room is spawned or limit is hit for each room
			var location = Vector2i(randi() % max_dungeon_size.y, randi() % max_dungeon_size.y)
			if generate_room_at(location):
				break
	"""
	var occupation = []
	for y in range(max_dungeon_size.y):
		occupation.append([])
		for x in range(max_dungeon_size.x):
			if dungeon_tiles.get_cell_source_id(Vector2i(x,y)) == -1:
				occupation[y].append(0)
			else:
				occupation[y].append(1)
	for y in range(max_dungeon_size.y):
		print(occupation[y])
	"""

func generate_room_at(location: Vector2i, room_id: int = -1, ignore_boundary: bool = false) -> bool:
	var pattern_id := room_id if room_id >= 0 else randi_range(0, dungeon_tiles.tile_set.get_patterns_count()-1)
	if not ignore_boundary:
		var suitable_patterns = get_fitting_patterns(max_dungeon_size - location)
		if suitable_patterns.is_empty():
			return false
		if pattern_id not in suitable_patterns:
			pattern_id = suitable_patterns[randi_range(0, suitable_patterns.size()-1)]
		var pattern_size := dungeon_tiles.tile_set.get_pattern(pattern_id).get_size()
		for x in range(pattern_size.x):
			for y in range(pattern_size.y):
				if dungeon_tiles.get_cell_source_id(location + Vector2i(x,y)) != -1:
					return false
	dungeon_tiles.set_pattern(location, dungeon_tiles.tile_set.get_pattern(pattern_id))
	return true
	
func get_fitting_patterns(size: Vector2i) -> Array[int]:
	var suitable_patterns: Array[int] = []
	for pattern in range(dungeon_tiles.tile_set.get_patterns_count()):
		var pattern_size := dungeon_tiles.tile_set.get_pattern(pattern).get_size()
		if pattern_size.x <= size.x and pattern_size.y <= size.y:
			suitable_patterns.append(pattern)
	return suitable_patterns
	
func get_max_room_size_at(location: Vector2i) -> Vector2i:
	var room_size := Vector2i(0,0)
	
	return room_size
