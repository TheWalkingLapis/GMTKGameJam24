extends CharacterBody2D
class_name Enemy

signal enemy_dead(value: int)

@export var movement_speed: float = 10.0
@export var value: int = 0 # for progression at altar

func init(player_node: Player, start_pos: Vector2):
	print("No constructor for enemy")

func _ready():
	pass
func _process(delta):
	pass

func die():
	enemy_dead.emit(value)
	queue_free()
