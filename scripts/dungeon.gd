extends Node2D
class_name Dungeon

class Room:
	var layout: Room_Layout
	var layout_id: int
	var local_coords: Vector2i
	var door_slots: Dictionary
	static func create(layout_, layout_id_, coords_, room_rotation) -> Room:
		var room:= Room.new()
		room.layout_id = layout_id_
		room.layout = layout_
		room.local_coords = coords_
		# TODO change with rotation
		match room_rotation:
			0:
				room.door_slots["N"] = layout_.door_directions["N"]
				room.door_slots["E"] = layout_.door_directions["E"]
				room.door_slots["S"] = layout_.door_directions["S"]
				room.door_slots["W"] = layout_.door_directions["W"]
			1:
				room.door_slots["N"] = layout_.door_directions["W"]
				room.door_slots["E"] = layout_.door_directions["N"]
				room.door_slots["S"] = layout_.door_directions["E"]
				room.door_slots["W"] = layout_.door_directions["S"]
			2:
				room.door_slots["N"] = layout_.door_directions["S"]
				room.door_slots["E"] = layout_.door_directions["W"]
				room.door_slots["S"] = layout_.door_directions["N"]
				room.door_slots["W"] = layout_.door_directions["E"]
			3:
				room.door_slots["N"] = layout_.door_directions["E"]
				room.door_slots["E"] = layout_.door_directions["S"]
				room.door_slots["S"] = layout_.door_directions["W"]
				room.door_slots["W"] = layout_.door_directions["N"]
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
	for child in $Room_Layout.get_children():
		if child is Room_Layout:
			room_layouts.append(child)
	num_room_layouts = room_layouts.size()
	generate_room_patterns()

func _process(delta):
	if Input.is_action_just_pressed("generate_layer"):
		clear_layer()
		while(not generate_dungeon_layer(30)): clear_layer()
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
	var spawn_room_candidates = get_room_layout_with_min_doors(3)
	var spawn_room_idx = spawn_room_candidates[randi() % spawn_room_candidates.size()]
	spawn_room_at_grid(Vector2i(max_dungeon_size.x / 2, max_dungeon_size.y / 2), spawn_room_idx)
	
	var queue: Array[Vector2i]
	queue.push_back(Vector2i(max_dungeon_size.x / 2, max_dungeon_size.y / 2))
	while(not queue.is_empty()):
		var coord = queue.pop_front()
		print("--------------")
		print(room_counter)
		print(dungeon_rooms.keys().size())
		print(dungeon_rooms.keys())
		print("--------------")
		print("Room: " + str(coord))
		for i in range(4):
			var next_dir = coord
			match i:
				0: # N
					print("    north?")
					if not dungeon_rooms[coord].door_slots["N"]:
						print("    X no")
						continue
					if not coord.y == 0:
						next_dir.y -= 1
					else:
						print("    X no")
						continue
					
				1: # E
					print("    east?")
					if not dungeon_rooms[coord].door_slots["E"]:
						print("    X no")
						continue
					if not coord.x == max_dungeon_size.x - 1:
						next_dir.x += 1
					else:
						print("    X no")
						continue
				2: # S
					print("    south?")
					if not dungeon_rooms[coord].door_slots["S"]:
						print("    X no")
						continue
					if not coord.y == max_dungeon_size.y - 1:
						next_dir.y += 1
					else:
						print("    X no")
						continue
				3: # W
					print("    west?")
					if not dungeon_rooms[coord].door_slots["W"]:
						print("    X no")
						continue
					if not coord.x == 0:
						next_dir.x -= 1
					else:
						print("    X no")
						continue
			print("    candidate: " + str(next_dir))
			if room_counter >= num_rooms:
				print("        X max rooms reached")
				break
			if randf() < 0.5:
				print("        X random continue")
				continue
			if dungeon_occupation_grid[next_dir.y][next_dir.x]:
				print("        X room exists")
				continue
			if get_cardinal_neighbour_count(next_dir) > 1:
				print("        X too many neighbours (" + str(get_cardinal_neighbour_count(next_dir)) + ")")
				continue
			var next_room_idx = randi() % room_layouts.size()
			print("        layout: " + str(next_room_idx))
			var layout_type := room_layouts[next_room_idx].get_room_door_type()
			print("        layout type: " + str(layout_type))
			var room_rotation = 0
			match layout_type:
				Room_Layout.RoomDoorType.ONE:
					if room_layouts[next_room_idx].door_directions["N"]: room_rotation = 2
					elif room_layouts[next_room_idx].door_directions["E"]: room_rotation = 3
					elif room_layouts[next_room_idx].door_directions["S"]: room_rotation = 0
					elif room_layouts[next_room_idx].door_directions["W"]: room_rotation = 1
					room_rotation += i
					room_rotation %= 4
				Room_Layout.RoomDoorType.TWO_CORNER:
					room_rotation = 0 # TODO
				Room_Layout.RoomDoorType.TWO_STRAIGHT:
					if room_layouts[next_room_idx].door_directions["N"]: room_rotation = 0
					elif room_layouts[next_room_idx].door_directions["E"]: room_rotation = 1
					elif room_layouts[next_room_idx].door_directions["S"]: room_rotation = 0
					elif room_layouts[next_room_idx].door_directions["W"]: room_rotation = 1
					room_rotation += i
					room_rotation %= 2
				Room_Layout.RoomDoorType.THREE:
					if not room_layouts[next_room_idx].door_directions["N"]: room_rotation = 2
					elif not room_layouts[next_room_idx].door_directions["E"]: room_rotation = 3
					elif not room_layouts[next_room_idx].door_directions["S"]: room_rotation = 0
					elif not room_layouts[next_room_idx].door_directions["W"]: room_rotation = 1
					room_rotation += i
					room_rotation %= 4
					room_rotation += randi_range(1, 3)
					room_rotation %= 4
				Room_Layout.RoomDoorType.ALL:
					room_rotation = 0
			print("        rotation: " + str(room_rotation))
			if spawn_room_at_grid(next_dir, next_room_idx, room_rotation):
				print("        O room spawn success")
				queue.push_back(next_dir)
				room_counter += 1
		if room_counter >= num_rooms:
			print("X max rooms reached")
			break
	place_doors_where_connected()
	print("Spawned " + str(room_counter) + " Rooms")
	return room_counter > 0.5 * num_rooms

func grid_to_world_pos(grid_coords: Vector2i) -> Vector2:
	return (16 * grid_coords * tiles_per_room_unit) as Vector2 + Vector2(16 * 0.5 * tiles_per_room_unit, 16 * 0.5 * tiles_per_room_unit)
func get_tilemap_corner_from_grid_coords(grid_coords: Vector2i) -> Vector2i:
	return grid_coords * tiles_per_room_unit
func get_local_door_coords(dir: int) -> Vector2i:
		if dir == 0:
			return Vector2i(tiles_per_room_unit / 2, 0)
		if dir == 1:
			return Vector2i(tiles_per_room_unit - 1, tiles_per_room_unit / 2)
		if dir == 2:
			return Vector2i(tiles_per_room_unit / 2, tiles_per_room_unit - 1)
		if dir == 3:
			return Vector2i(0, tiles_per_room_unit / 2)
		return Vector2i(-1,-1)
	
func spawn_room_at_grid(grid_coord: Vector2i, room_layout_idx: int, room_rotation: int = 0) -> bool:
	if room_layout_idx >= num_room_layouts:
		return false
	var room := room_layouts[room_layout_idx]
	if dungeon_occupation_grid[grid_coord.y][grid_coord.x]:
		return false
	var location = get_tilemap_corner_from_grid_coords(grid_coord)
	draw_and_rotate_pattern(location, room_patterns[room_layouts[room_layout_idx]], room_rotation)
	dungeon_occupation_grid[grid_coord.y][grid_coord.x] = true
	var room_instance = Room.create(room, room_layout_idx, grid_coord, room_rotation)
	dungeon_rooms[grid_coord] = room_instance
	return true

func place_doors_where_connected():
	for y in range(max_dungeon_size.y):
		for x in range(max_dungeon_size.x):
			if dungeon_occupation_grid[y][x]:
				print(str(Vector2i(x,y)))
				if not y == max_dungeon_size.y - 1:
					if dungeon_occupation_grid[y+1][x]:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(2), 0, Vector2i(3,0))
					else:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(2), 0, Vector2i(0,0))
				else:
					dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(2), 0, Vector2i(0,0))
				if not x == max_dungeon_size.x - 1:
					if dungeon_occupation_grid[y][x+1]:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(1), 0, Vector2i(3,0))
					else:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(1), 0, Vector2i(0,0))
				else:
					dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(1), 0, Vector2i(0,0))
				if not y == 0:
					if dungeon_occupation_grid[y-1][x]:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(0), 0, Vector2i(3,0))
					else:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(0), 0, Vector2i(0,0))
				else:
					dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(0), 0, Vector2i(0,0))
				if not x == 0:
					if dungeon_occupation_grid[y][x-1]:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(3), 0, Vector2i(3,0))
					else:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(3), 0, Vector2i(0,0))
				else:
					dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + get_local_door_coords(3), 0, Vector2i(0,0))

func get_room_layout_with_exact_doors(num_doors: int) -> Array[int]:
	var rooms: Array[int] = []
	for idx in range(num_room_layouts):
		var room = room_layouts[idx]
		if room.get_num_doors() == num_doors:
			rooms.append(idx)
	return rooms
func get_room_layout_with_min_doors(num_doors: int) -> Array[int]:
	var rooms: Array[int] = []
	for idx in range(num_room_layouts):
		var room = room_layouts[idx]
		if room.get_num_doors() >= num_doors:
			rooms.append(idx)
	return rooms

func draw_and_rotate_pattern(location: Vector2i, pattern: TileMapPattern, room_rotation: int):
	var tmp_tile_map = $CopyTileMapLayer
	tmp_tile_map.set_pattern(Vector2i(-tiles_per_room_unit/2,-tiles_per_room_unit/2), pattern)
	for x in range(tiles_per_room_unit):
		for y in range(tiles_per_room_unit):
			var vec = Vector2i(x-(tiles_per_room_unit/2),y-(tiles_per_room_unit/2))
			var coord = vec
			match room_rotation:
				0:
					coord = vec
				1:
					coord = Vector2i(-vec.y, vec.x)
				2:
					coord = Vector2i(-vec.x, -vec.y)
				3:
					coord = Vector2i(vec.y, -vec.x)
			coord += Vector2i(tiles_per_room_unit/2,tiles_per_room_unit/2)
			dungeon_tile_map.set_cell(location + coord, tmp_tile_map.get_cell_source_id(vec), tmp_tile_map.get_cell_atlas_coords(vec))
	tmp_tile_map.clear()

func generate_room_patterns():
	for id in range(room_layouts.size()):
		var room = room_layouts[id]
		room_patterns[room] = room.get_room_pattern()
