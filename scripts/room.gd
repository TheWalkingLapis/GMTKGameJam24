extends TileMapLayer
class_name Room_Layout

enum RoomDoorType {NONE, ONE, TWO_CORNER, TWO_STRAIGHT, THREE, ALL}

var pattern_id: int = -1
## Whether there exists a door in N E S W direction
@export var door_directions: Dictionary = {"N": false, "E": false, "S": false, "W": false}

func get_num_doors() -> int:
	var doors = 0
	if door_directions["N"]: doors += 1
	if door_directions["E"]: doors += 1
	if door_directions["S"]: doors += 1
	if door_directions["W"]: doors += 1
	return doors

func get_room_door_type() -> RoomDoorType:
	var doors = get_num_doors()
	match doors:
		1:
			return RoomDoorType.ONE
		2:
			if (door_directions["N"] and door_directions["S"]) or (door_directions["E"] and door_directions["W"]):
				return RoomDoorType.TWO_STRAIGHT
			return RoomDoorType.TWO_CORNER
		3:
			return RoomDoorType.THREE
		4:
			return RoomDoorType.ALL
	return RoomDoorType.NONE

func get_room_pattern() -> TileMapPattern:
	var pattern_coords = []
	for x in range(Dungeon.tiles_per_room_unit):
		for y in range(Dungeon.tiles_per_room_unit):
			pattern_coords.append(Vector2i(x,y))
	return get_pattern(pattern_coords)
