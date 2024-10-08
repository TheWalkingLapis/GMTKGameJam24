extends Area2D
class_name Interactable_Entity

signal interactable_replace(grid_idx: Vector2i, atlas_idx: Vector2i)
signal hole_interaction

var tile_pos: Vector2i = Vector2i(0,0)
var atlas_idx: Vector2i = Vector2i(-1,-1)
var needs_input: bool = false
var is_fire: bool = false
var is_water: bool = false

var player_inside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(pos, tile_idx):
	needs_input = false
	tile_pos = pos
	if tile_idx == Vector2i(0,1):
		atlas_idx = Vector2i(3,8) if randi() % 2 == 0 else Vector2i(2,8)
	elif tile_idx == Vector2i(0,6):
		atlas_idx = Vector2i(1,6)
		needs_input = true
	elif tile_idx == Vector2i(0,7):
		atlas_idx = Vector2i(0,7)
		needs_input = true
	else:
		atlas_idx = Vector2i(-1,-1)
	is_fire = tile_idx in [Vector2i(0,0), Vector2i(0,1)]
	is_water = tile_idx in [Vector2i(2,2), Vector2i(0,3), Vector2i(2,3)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not needs_input: return
	if player_inside and Input.is_action_just_pressed("interact"):
		# altar
		if atlas_idx == Vector2i(1,6):
			interactable_replace.emit(tile_pos, atlas_idx)
		# hole
		if atlas_idx == Vector2i(0,7):
			hole_interaction.emit()

func _on_body_entered(body):
	if body is Player:
		player_inside = true
		if is_fire and body.needs_fire_charges():
			body.add_fire_charge()
			interactable_replace.emit(tile_pos, atlas_idx)
			queue_free()
			return
		if is_water and body.needs_water_charges():
			body.add_water_charge()
			interactable_replace.emit(tile_pos, atlas_idx)
			queue_free()
			return

func _on_body_exited(body):
	player_inside = false
