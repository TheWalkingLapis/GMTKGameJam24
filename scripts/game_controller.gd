extends Node2D

var dungeon_rooms: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	load_next_dungeon_layer()

func load_next_dungeon_layer():
	$Dungeon.clear_layer()
	dungeon_rooms.clear()
	while(not $Dungeon.generate_dungeon_layer(30)): $Dungeon.clear_layer()
	var room_coords: Array[Vector2i] = $Dungeon.get_used_room_coords()
	for coord in room_coords:
		dungeon_rooms[coord] = 0
	dungeon_rooms[$Dungeon.world_to_grid_pos($Player.position)] = 1
	$Camera2D.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2)
	$Player.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2)
	# TODO clear Enemies

func _process(delta):
	if Input.is_action_just_released("zoom_in"):
		$Camera2D.zoom *= 1.2
	if Input.is_action_just_released("zoom_out"):
		$Camera2D.zoom *= 0.8
	if Input.is_action_just_pressed("generate_layer"):
		load_next_dungeon_layer()
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
				$Dungeon.complete_room(room_pos)
				print("Completed Room " + str(room_pos))
				e_node.queue_free()
