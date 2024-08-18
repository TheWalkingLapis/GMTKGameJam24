extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	load_next_dungeon_layer()

func load_next_dungeon_layer():
	$Dungeon.clear_layer()
	while(not $Dungeon.generate_dungeon_layer(30)): $Dungeon.clear_layer()
	$Camera2D.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2)
	$Player.position = $Dungeon.grid_to_world_pos($Dungeon.max_dungeon_size / 2)
	# TODO clear Enemies

func _process(delta):
	$Camera2D.position = $Player.position
	if Input.is_action_just_released("zoom_in"):
		$Camera2D.zoom *= 1.2
	if Input.is_action_just_released("zoom_out"):
		$Camera2D.zoom *= 0.8
		
	pass
