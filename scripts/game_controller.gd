extends Node2D

var dungeon_rooms: Dictionary
@onready var player: Player = $Player
@onready var dungeon: Dungeon = $Dungeon

# Called when the node enters the scene tree for the first time.
func _ready():
	dungeon.set_player(player)
	load_next_dungeon_layer()
	dungeon.enemy_dead.connect(player.set_scaling)
	dungeon.trigger_next_floor.connect(handle_floor_done)

func handle_floor_done():
	load_next_dungeon_layer()

func load_next_dungeon_layer():
	$Dungeon.clear_layer()
	dungeon_rooms.clear()
	while(not $Dungeon.generate_dungeon_layer(5)): $Dungeon.clear_layer()
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

func _process(delta):
	if Input.is_action_just_released("zoom_in"):
		$Camera2D.zoom *= 1.2
		print($Camera2D.zoom)
	if Input.is_action_just_released("zoom_out"):
		$Camera2D.zoom *= 0.8
		print($Camera2D.zoom)
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
