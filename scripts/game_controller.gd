extends Node2D

signal win
signal room_change(rooms: Array[int])
signal layer_change(layer_one_indexed: int)

var dungeon_rooms: Dictionary
@onready var player: Player = $Player
@onready var dungeon: Dungeon = $Dungeon
var dungeon_layer: int = 0 :
	set(val):
		dungeon_layer = val
		layer_change.emit(val + 1)
var last_dungeon_pos = Vector2i(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	dungeon.set_player(player)
	dungeon.enemy_dead.connect(player.set_scaling)
	dungeon.trigger_next_floor.connect(handle_floor_done)

func reset():
	dungeon_layer = 0
	last_dungeon_pos = Vector2i(-1,-1)
	player.reset()
	load_next_dungeon_layer()
	
func handle_floor_done():
	dungeon_layer += 1
	if dungeon_layer >= 3:
		win.emit()
		return
	load_next_dungeon_layer()

func load_next_dungeon_layer():
	$Dungeon.clear_layer()
	dungeon_rooms.clear()
	while(not $Dungeon.generate_dungeon_layer(6 + (dungeon_layer * 2))): $Dungeon.clear_layer()
	$Dungeon.calculate_monster_number()
	var room_coords: Array[Vector2i] = $Dungeon.get_used_room_coords()
	for coord in room_coords:
		dungeon_rooms[coord] = 0
	$Player.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2)
	dungeon_rooms[$Dungeon.world_to_grid_pos($Player.position)] = 1
	var neighbours: Array[int] = []
	$Dungeon.complete_room($Dungeon.world_to_grid_pos($Player.position), neighbours)
	$Camera2D.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2)
	for e_node in $Enemies.get_children():
		for e in e_node.get_children():
			e.queue_free()
		e_node.queue_free()
	if dungeon_layer != 0: $HoleSound.play()
	var player_dungeon_pos = $Dungeon.world_to_grid_pos($Player.position)
	var rooms: Array[int] = [get_room_state(player_dungeon_pos + Vector2i(-1,-1)), 
									get_room_state(player_dungeon_pos + Vector2i(0,-1)), 
									get_room_state(player_dungeon_pos + Vector2i(1,-1)),
									get_room_state(player_dungeon_pos + Vector2i(-1,0)), 
									get_room_state(player_dungeon_pos), 
									get_room_state(player_dungeon_pos + Vector2i(1,0)),
									get_room_state(player_dungeon_pos + Vector2i(-1,1)), 
									get_room_state(player_dungeon_pos + Vector2i(0,1)), 
									get_room_state(player_dungeon_pos + Vector2i(1,1))]
	room_change.emit(rooms)

func _process(delta):
	var player_world_pos: Vector2 = $Player.position
	var player_dungeon_pos: Vector2i = $Dungeon.world_to_grid_pos(player_world_pos)
	if dungeon_rooms.has(player_dungeon_pos):
		var room_val = dungeon_rooms[player_dungeon_pos]
		if room_val == 0:
			var enemy_node = Node2D.new()
			enemy_node.position = player_dungeon_pos
			enemy_node.set_name("en_" + str(player_dungeon_pos.x) + "_" + str(player_dungeon_pos.y))
			$Enemies.add_child(enemy_node)
			$Dungeon.activate_room(player_dungeon_pos, $Player, enemy_node)
			dungeon_rooms[player_dungeon_pos] = 1
		if player_dungeon_pos != last_dungeon_pos:
			last_dungeon_pos = player_dungeon_pos
			var rooms: Array[int] = [get_room_state(player_dungeon_pos + Vector2i(-1,-1)), 
									get_room_state(player_dungeon_pos + Vector2i(0,-1)), 
									get_room_state(player_dungeon_pos + Vector2i(1,-1)),
									get_room_state(player_dungeon_pos + Vector2i(-1,0)), 
									get_room_state(player_dungeon_pos), 
									get_room_state(player_dungeon_pos + Vector2i(1,0)),
									get_room_state(player_dungeon_pos + Vector2i(-1,1)), 
									get_room_state(player_dungeon_pos + Vector2i(0,1)), 
									get_room_state(player_dungeon_pos + Vector2i(1,1))]
			room_change.emit(rooms)
	$Camera2D.position = player_world_pos
	
	for e_node in $Enemies.get_children():
		if e_node is Node2D:
			if e_node.get_child_count() == 0:
				var room_pos = e_node.position as Vector2i
				var completed_neighbours: Array[int] = []
				if dungeon_rooms.has(room_pos + Vector2i(0,-1)):
					if dungeon_rooms[room_pos + Vector2i(0,-1)] == 1: completed_neighbours.append(0)
				if dungeon_rooms.has(room_pos + Vector2i(1,0)):
					if dungeon_rooms[room_pos + Vector2i(1,0)] == 1: completed_neighbours.append(1)
				if dungeon_rooms.has(room_pos + Vector2i(0,1)):
					if dungeon_rooms[room_pos + Vector2i(0,1)] == 1: completed_neighbours.append(2)
				if dungeon_rooms.has(room_pos + Vector2i(-1,0)):
					if dungeon_rooms[room_pos + Vector2i(-1,0)] == 1: completed_neighbours.append(3)
				$Dungeon.complete_room(room_pos, completed_neighbours)
				e_node.queue_free()
				
				var rooms: Array[int] = [get_room_state(player_dungeon_pos + Vector2i(-1,-1)), 
									get_room_state(player_dungeon_pos + Vector2i(0,-1)), 
									get_room_state(player_dungeon_pos + Vector2i(1,-1)),
									get_room_state(player_dungeon_pos + Vector2i(-1,0)), 
									get_room_state(player_dungeon_pos), 
									get_room_state(player_dungeon_pos + Vector2i(1,0)),
									get_room_state(player_dungeon_pos + Vector2i(-1,1)), 
									get_room_state(player_dungeon_pos + Vector2i(0,1)), 
									get_room_state(player_dungeon_pos + Vector2i(1,1))]
				room_change.emit(rooms)

func get_room_state(dungeon_coord: Vector2i) -> int:
	if dungeon_coord == dungeon.spawn_room_coord:
		return 4
	if dungeon_rooms.has(dungeon_coord):
		if dungeon_rooms[dungeon_coord] == 0:
			return 1
		for e_n in $Enemies.get_children():
			if e_n.name == ("en_" + str(dungeon_coord.x) + "_" + str(dungeon_coord.y)):
				if e_n.get_child_count() == 0: return 3
				return 2
		return 3
	return 0
