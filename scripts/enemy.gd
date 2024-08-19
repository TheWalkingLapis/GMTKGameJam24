extends CharacterBody2D
class_name Enemy

signal enemy_dead

@export var movement_speed: float = 1700.0
@export var value: int = 0 # for progression at altar
@export var melee_damage: int = 10
var melee_damage_cooldown: float = 0.5
var melee_damage_cd_tracker: float = 0.0

func init(player_node: Player, start_pos: Vector2):
	print("No constructor for enemy")

func _ready():
	pass
func _process(delta):
	pass

func die():
	enemy_dead.emit()
	queue_free()
