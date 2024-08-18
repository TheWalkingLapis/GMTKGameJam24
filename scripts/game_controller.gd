extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2)
	$Player.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2)
	$Slime.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2 + Vector2i(1,0))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Camera2D.position = $Player.position
	if Input.is_action_just_released("zoom_in"):
		$Camera2D.zoom *= 1.2
	if Input.is_action_just_released("zoom_out"):
		$Camera2D.zoom *= 0.8
		
	pass
