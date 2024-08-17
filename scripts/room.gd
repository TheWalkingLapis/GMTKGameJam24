extends TileMapLayer
class_name Room

@export var size_dungeon_units: Vector2i = Vector2i(1,1)
var pattern_id: int = -1
## Whether there exists a door in N E S W direction
@export var door_directions: Dictionary = {"N": false, "E": false, "S": false, "W": false}

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_room_pattern() -> TileMapPattern:
	#pattern_id = tile_map.tile_set.get_patterns_count() + id
	var pattern_coords = []
	for x in range(Dungeon.tiles_per_room_unit * size_dungeon_units.x):
		for y in range(Dungeon.tiles_per_room_unit * size_dungeon_units.y):
			pattern_coords.append(Vector2i(x,y))
	return get_pattern(pattern_coords)
