extends Node2D
class_name Dungeon

@export var max_dungeon_size: Vector2i = Vector2(10, 10)

var room_layouts: Array[Room]
var num_room_layouts: int
var room_patterns: Dictionary
@onready var dungeon_tile_map: TileMapLayer = $"Dungeon_TileMap"
var dungeon_occupation_grid: Array[Array] = []
static var tiles_per_room_unit: int = 15

func _ready():
	# init occupation grid
	for y in range(max_dungeon_size.y):
		dungeon_occupation_grid.append([])
		for x in range(max_dungeon_size.x):
			dungeon_occupation_grid[y].append(false)
	
	# fetch room layouts
	for child in $Rooms.get_children():
		if child is Room:
			room_layouts.append(child)
	num_room_layouts = room_layouts.size()
	generate_room_patterns()

func _process(delta):
	if Input.is_action_just_pressed("generate_layer"):
		generate_dungeon_layer()


func generate_dungeon_layer():
	spawn_room_at_grid(Vector2i(0,0), 0)
	spawn_room_at_grid(Vector2i(1,0), 0)
	spawn_room_at_grid(Vector2i(0,1), 1)
	
func get_tilemap_corner_from_grid_coords(grid_coords: Vector2i):
	return grid_coords * tiles_per_room_unit
	
func spawn_room_at_grid(grid_coord: Vector2i, room_layout_idx: int) -> bool:
	if room_layout_idx >= num_room_layouts:
		return false
	var room := room_layouts[room_layout_idx]
	for x in range(room.size_dungeon_units.x):
		for y in range(room.size_dungeon_units.y):
			if dungeon_occupation_grid[grid_coord.y + y][grid_coord.x + x]:
				return false
	var location = get_tilemap_corner_from_grid_coords(grid_coord)
	dungeon_tile_map.set_pattern(location, room_patterns[room_layouts[room_layout_idx]])
	for x in range(room.size_dungeon_units.x):
		for y in range(room.size_dungeon_units.y):
			dungeon_occupation_grid[grid_coord.y + y][grid_coord.x + x] = true
	return true

func generate_room_patterns():
	for id in range(room_layouts.size()):
		var room = room_layouts[id]
		room_patterns[room] = room.get_room_pattern()
