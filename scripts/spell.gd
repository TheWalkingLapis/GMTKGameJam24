extends CharacterBody2D
class_name Spell

signal enemy_hit(enemy: Object)

enum SpellName {FIREBALL}

@export var base_damage: int = 0
@export var flight_speed: float = 10.0

var cast_direction: Vector2

func init(dir: Vector2):
	print("Someone didn't implement the init func D:")

func _physics_process(delta):
	var collision := move_and_collide(cast_direction * flight_speed * delta)
	if collision:
		var collider = collision.get_collider()
		enemy_hit.emit(collider)
		print(collider)
