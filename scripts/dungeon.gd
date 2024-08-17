extends Node2D
class_name Dungeon

class Room:
	var layout: Room_Layout
	var layout_id: int
	var local_coords: Vector2i
	static func create(layout_, layout_id_, coords_) -> Room:
		var room:= Room.new()
		room.layout_id = layout_id_
		room.layout = layout_
		room.local_coords = coords_
		return room
		

@export var max_dungeon_size: Vector2i = Vector2(10, 10)

var room_layouts: Array[Room_Layout]
var num_room_layouts: int
var room_patterns: Dictionary
@onready var dungeon_tile_map: TileMapLayer = $"Dungeon_TileMap"
var dungeon_occupation_grid: Array[Array] = []
var dungeon_rooms: Dictionary
static var tiles_per_room_unit: int = 15

func _ready():
	# init occupation grid
	for y in range(max_dungeon_size.y):
		dungeon_occupation_grid.append([])
		for x in range(max_dungeon_size.x):
			dungeon_occupation_grid[y].append(false)
	
	# fetch room layouts
	for child in $Rooms.get_children():
		if child is Room_Layout:
			room_layouts.append(child)
	num_room_layouts = room_layouts.size()
	generate_room_patterns()

func _process(delta):
	if Input.is_action_just_pressed("generate_layer"):
		clear_layer()
		while(not generate_dungeon_layer(12)): clear_layer()
	if Input.is_action_just_pressed("clear_layer"):
		clear_layer()

func clear_layer():
	dungeon_tile_map.clear()
	dungeon_rooms.clear()
	for y in range(max_dungeon_size.y):
		for x in range(max_dungeon_size.x):
			dungeon_occupation_grid[y][x] = false

func get_cardinal_neighbour_count(grid_coord: Vector2i) -> int:
	var count = 0
	if not grid_coord.x == 0:
		if dungeon_occupation_grid[grid_coord.y][grid_coord.x - 1]:
			count += 1
	if not grid_coord.y == 0:
		if dungeon_occupation_grid[grid_coord.y - 1][grid_coord.x]:
			count += 1
	if not grid_coord.x == max_dungeon_size.x - 1:
		if dungeon_occupation_grid[grid_coord.y][grid_coord.x + 1]:
			count += 1
	if not grid_coord.y == max_dungeon_size.y - 1:
		if dungeon_occupation_grid[grid_coord.y + 1][grid_coord.x]:
			count += 1
	return count

func generate_dungeon_layer(num_rooms: int) -> bool:
	var room_counter = 1
	var spawn_room_candidates = get_room_layout_with_min_doors(2)
	# TODO select random room layout as spawn room
	spawn_room_at_grid(Vector2i(max_dungeon_size.x / 2, max_dungeon_size.y / 2), 0)
	
	var queue: Array[Vector2i]
	queue.push_back(Vector2i(max_dungeon_size.x / 2, max_dungeon_size.y / 2))
	while(not queue.is_empty()):
		var coord = queue.pop_front()
		for i in range(4):
			var next_dir = coord
			match i:
				0:
					if not coord.x == 0:
						next_dir.x -= 1
					else:
						continue
				1:
					if not coord.y == 0:
						next_dir.y -= 1
					else:
						continue
				2:
					if not coord.x == max_dungeon_size.x - 1:
						next_dir.x += 1
					else:
						continue
				3:
					if not coord.y == max_dungeon_size.y - 1:
						next_dir.y += 1
					else:
						continue
			if room_counter >= num_rooms:
				break
			if randf() < 0.5:
				continue
			if dungeon_occupation_grid[next_dir.y][next_dir.x]:
				continue
			if get_cardinal_neighbour_count(next_dir) > 1:
				continue
			spawn_room_at_grid(next_dir, 0)
			queue.push_back(next_dir)
			room_counter += 1
		if room_counter >= num_rooms:
			break
	return room_counter > 0.5 * num_rooms

func grid_to_world_pos(grid_coords: Vector2i) -> Vector2:
	return (16 * grid_coords * tiles_per_room_unit) as Vector2 + Vector2(16 * 0.5 * tiles_per_room_unit, 16 * 0.5 * tiles_per_room_unit)
func get_tilemap_corner_from_grid_coords(grid_coords: Vector2i) -> Vector2i:
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
			var room_instance = Room.create(room, room_layout_idx, grid_coord)
			dungeon_rooms[Vector2i(x,y)] = room_instance
	return true

func get_room_layout_with_exact_doors(num_doors: int) -> Array[int]:
	var rooms = []
	for idx in range(num_room_layouts):
		var room = room_layouts[idx]
		if room.get_num_doors() == num_doors:
			rooms.append(room)
	return rooms
func get_room_layout_with_min_doors(num_doors: int) -> Array[int]:
	var rooms = []
	for idx in range(num_room_layouts):
		var room = room_layouts[idx]
		if room.get_num_doors() >= num_doors:
			rooms.append(room)
	return rooms

func generate_room_patterns():
	for id in range(room_layouts.size()):
		var room = room_layouts[id]
		room_patterns[room] = room.get_room_pattern()
