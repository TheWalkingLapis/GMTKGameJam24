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

@export_category("Debug")
@export var generation_output: bool = false

@export_category("Settings")
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
	for child in $Room_Layouts.get_children():
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
		if generation_output:
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
					if generation_output: print("    north?")
					if not dungeon_rooms[coord].door_slots["N"]:
						if generation_output: print("    X no")
						continue
					if not coord.y == 0:
						next_dir.y -= 1
					else:
						if generation_output: print("    X no")
						continue
					
				1: # E
					if generation_output: print("    east?")
					if not dungeon_rooms[coord].door_slots["E"]:
						if generation_output: print("    X no")
						continue
					if not coord.x == max_dungeon_size.x - 1:
						next_dir.x += 1
					else:
						if generation_output: print("    X no")
						continue
				2: # S
					if generation_output: print("    south?")
					if not dungeon_rooms[coord].door_slots["S"]:
						if generation_output: print("    X no")
						continue
					if not coord.y == max_dungeon_size.y - 1:
						next_dir.y += 1
					else:
						if generation_output: print("    X no")
						continue
				3: # W
					if generation_output: print("    west?")
					if not dungeon_rooms[coord].door_slots["W"]:
						if generation_output: print("    X no")
						continue
					if not coord.x == 0:
						next_dir.x -= 1
					else:
						if generation_output: print("    X no")
						continue
			if generation_output:print("    candidate: " + str(next_dir))
			if room_counter >= num_rooms:
				if generation_output: print("        X max rooms reached")
				break
			if randf() < 0.5:
				if generation_output: print("        X random continue")
				continue
			if dungeon_occupation_grid[next_dir.y][next_dir.x]:
				if generation_output: print("        X room exists")
				continue
			if get_cardinal_neighbour_count(next_dir) > 1:
				if generation_output: print("        X too many neighbours (" + str(get_cardinal_neighbour_count(next_dir)) + ")")
				continue
			var next_room_idx = randi() % room_layouts.size()
			if generation_output: print("        layout: " + str(next_room_idx))
			var layout_type := room_layouts[next_room_idx].get_room_door_type()
			if generation_output: print("        layout type: " + str(layout_type))
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
			if generation_output: print("        rotation: " + str(room_rotation))
			if spawn_room_at_grid(next_dir, next_room_idx, room_rotation):
				if generation_output: print("        O room spawn success")
				queue.push_back(next_dir)
				room_counter += 1
		if room_counter >= num_rooms:
			if generation_output: print("X max rooms reached")
			break
	place_doors_where_connected()
	if generation_output: print("Spawned " + str(room_counter) + " Rooms")
	return room_counter > 0.5 * num_rooms

func grid_to_world_pos(grid_coords: Vector2i) -> Vector2:
	return (16 * grid_coords * tiles_per_room_unit) as Vector2 + Vector2(16 * 0.5 * tiles_per_room_unit, 16 * 0.5 * tiles_per_room_unit)
func get_tilemap_corner_from_grid_coords(grid_coords: Vector2i) -> Vector2i:
	return grid_coords * tiles_per_room_unit
func get_local_door_coords(dir: int) -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	if dir == 0:
		var vec = Vector2i(tiles_per_room_unit / 2, 0)
		coords.append(vec + Vector2i(-2, 0))
		coords.append(vec + Vector2i(-1, 0))
		coords.append(vec)
		coords.append(vec + Vector2i(1, 0))
		coords.append(vec + Vector2i(2, 0))
	if dir == 1:
		var vec = Vector2i(tiles_per_room_unit - 1, tiles_per_room_unit / 2)
		coords.append(vec + Vector2i(0, -2))
		coords.append(vec + Vector2i(0, -1))
		coords.append(vec)
		coords.append(vec + Vector2i(0, 1))
		coords.append(vec + Vector2i(0, 2))
	if dir == 2:
		var vec = Vector2i(tiles_per_room_unit / 2, tiles_per_room_unit - 1)
		coords.append(vec + Vector2i(-2, 0))
		coords.append(vec + Vector2i(-1, 0))
		coords.append(vec)
		coords.append(vec + Vector2i(1, 0))
		coords.append(vec + Vector2i(2, 0))
	if dir == 3:
		var vec = Vector2i(0, tiles_per_room_unit / 2)
		coords.append(vec + Vector2i(0, -2))
		coords.append(vec + Vector2i(0, -1))
		coords.append(vec)
		coords.append(vec + Vector2i(0, 1))
		coords.append(vec + Vector2i(0, 2))
	return coords
	
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
	var wall_top_idx = Vector2i(1,0)
	var wall_bot_idx = Vector2i(1,2)
	var wall_left_idx = Vector2i(0,1)
	var wall_right_idx = Vector2i(2,1)
	for y in range(max_dungeon_size.y):
		for x in range(max_dungeon_size.x):
			if dungeon_occupation_grid[y][x]:
				if not y == max_dungeon_size.y - 1:
					var door_coords = get_local_door_coords(2)
					if not dungeon_occupation_grid[y+1][x]:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[0], 0, wall_bot_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[1], 0, wall_bot_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[2], 0, wall_bot_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[3], 0, wall_bot_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[4], 0, wall_bot_idx)
				if not x == max_dungeon_size.x - 1:
					var door_coords = get_local_door_coords(1)
					if not dungeon_occupation_grid[y][x+1]:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[0], 0, wall_right_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[1], 0, wall_right_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[2], 0, wall_right_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[3], 0, wall_right_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[4], 0, wall_right_idx)
				if not y == 0:
					var door_coords = get_local_door_coords(0)
					if not dungeon_occupation_grid[y-1][x]:
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[0], 0, wall_top_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[1], 0, wall_top_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[2], 0, wall_top_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[3], 0, wall_top_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[4], 0, wall_top_idx)
				if not x == 0:
					if not dungeon_occupation_grid[y][x-1]:
						var door_coords = get_local_door_coords(3)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[0], 0, wall_left_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[1], 0, wall_left_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[2], 0, wall_left_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[3], 0, wall_left_idx)
						dungeon_tile_map.set_cell(tiles_per_room_unit * Vector2i(x,y) + door_coords[4], 0, wall_left_idx)

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
	var paste_tile_map = $Template_Paste_Pattern
	var rotate_tile_map = $Template_Rotate_Pattern
	paste_tile_map.set_pattern(Vector2i(-tiles_per_room_unit/2,-tiles_per_room_unit/2), pattern)
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
			rotate_tile_map.set_cell(coord, paste_tile_map.get_cell_source_id(vec), paste_tile_map.get_cell_atlas_coords(vec))
	for x in range(tiles_per_room_unit):
		for y in range(tiles_per_room_unit):
			var middle = rotate_tile_map.get_cell_atlas_coords(Vector2i(x,y)).x
			var top = rotate_tile_map.get_cell_atlas_coords(Vector2i(x,y-1)).x
			var right = rotate_tile_map.get_cell_atlas_coords(Vector2i(x+1,y)).x
			var bot = rotate_tile_map.get_cell_atlas_coords(Vector2i(x,y+1)).x
			var left = rotate_tile_map.get_cell_atlas_coords(Vector2i(x-1,y)).x
			var atlas_coords = mapping_room_description_to_tile(middle, top, left, right, bot)
			if atlas_coords != Vector2i(-1,-1):
				dungeon_tile_map.set_cell(location + Vector2i(x,y), 0, atlas_coords)
	paste_tile_map.clear()
	rotate_tile_map.clear()

func mapping_room_description_to_tile(middle, top, left, right, bottom) -> Vector2i:
	const nothing = -1
	const floor = 0
	const wall = 1
	if middle == nothing:
		return Vector2i(-1, -1)
	if middle == wall:
		if left == wall and right == wall:
			if bottom == floor:
				# normal wall
				return Vector2i(1, 0)
			else:
				# backwards normal wall
				return Vector2i(1, 2)
		if top == wall and bottom == wall:
			if right == floor:
				return Vector2i(0, 1)
			if left == floor:
				return Vector2i(2, 1)

		# outward corners
		if left == wall and bottom == wall and top == floor and right == floor:
			# top right
			return Vector2i(4, 0)
		if bottom == wall and right == wall and top == floor and left == floor:
			# top left
			return Vector2i(3, 0)
		if right == wall and top == wall and left == floor and bottom == floor:
			# bottom left
			return Vector2i(3, 1)
		if top == wall and left == wall and right == floor and bottom == floor:
			# bottom right
			return Vector2i(4, 1)

		# inward corners
		if left == wall and bottom == wall:
			# top right
			return Vector2i(2, 0)
		if right == wall and bottom == wall:
			# top left
			return Vector2i(0, 0)
		if right == wall and top == wall:
			# bottom left
			return Vector2i(0, 2)
		if left == wall and top == wall:
			# top right
			return Vector2i(2, 2)

	if middle == floor:
		const floor_selection_pos = Vector2i(6, 0)
		const floor_selection_amount = 6
		return floor_selection_pos + Vector2i(randi() % floor_selection_amount, 0)
	
	return Vector2i(-1, -1)

func generate_room_patterns():
	for id in range(room_layouts.size()):
		var room = room_layouts[id]
		room_patterns[room] = room.get_room_pattern()
