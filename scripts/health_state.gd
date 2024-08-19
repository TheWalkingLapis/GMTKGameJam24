extends Node
class_name HealthModule

signal hp_change(current_hp)
signal lethal_damage_taken

@export var max_hp: int = 100
var current_hp: int
var dead: bool

func _ready():
	current_hp = max_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func heal(hp: int):
	if dead: return
	current_hp += hp
	current_hp = clamp(current_hp, 0, max_hp)
	hp_change.emit(get_hp_percentage())

func take_damage(dmg: int):
	if dead: return
	current_hp -= dmg
	current_hp = clamp(current_hp, 0, max_hp)
	hp_change.emit(get_hp_percentage())
	if current_hp <= 0:
		dead = true
		lethal_damage_taken.emit()

func get_hp() -> int:
	return current_hp
func get_max_hp() -> int:
	return max_hp
func get_hp_percentage() -> float:
	return current_hp * 1.0 / max_hp
func is_dead() -> bool:
	return dead
