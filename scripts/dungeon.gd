extends Node2D

@export var max_dungeon_size: Vector2i = Vector2(10, 10)

@onready var dungeon_tiles: TileMapLayer = $"Dungeon_TileMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_layer_with_CA(0.45)
	#generate_dungeon_layer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("generate_layer"):
		generate_layer_with_CA(0.45)
		#generate_dungeon_layer()

func generate_layer_with_CA(prob: float, birth_thresh: int = 5, survival_thresh:int = 4, num_iters: int = 4):
	var cells = []
	for y in range(max_dungeon_size.y):
		cells.append([])
		for x in range(max_dungeon_size.x):
			cells[y].append(randf() <= prob)
	var cells_new = cells.duplicate(true)
	for iter in range(num_iters):
		for y in range(max_dungeon_size.y):
			for x in range(max_dungeon_size.x):
				var num_neighbours = 0
				for nx in range(-1, 2):
					for ny in range(-1, 2):
						if nx == 0 and ny == 0: continue
						var idx_x = x + nx
						var idx_y = y + ny
						if idx_x >= 0 and idx_x < max_dungeon_size.x and idx_y >= 0 and idx_y < max_dungeon_size.y:
							if cells[idx_y][idx_x]: num_neighbours += 1
				# is alive atm
				if cells[y][x]:
					cells_new[y][x] = num_neighbours >= survival_thresh
				# is dead atm
				else:
					cells_new[y][x] = num_neighbours >= birth_thresh
		cells = cells_new
		for y in range(max_dungeon_size.y):
			for x in range(max_dungeon_size.x):
				var tile_idx = 1 if cells[y][x] else 0
				dungeon_tiles.set_cell(Vector2i(x,y), 0, Vector2i(tile_idx, 0))

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
