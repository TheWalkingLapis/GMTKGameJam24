extends CharacterBody2D
class_name Spell

signal hit(obj: Object)
signal projectile_dead(spell: Spell)

enum SpellName {FIREBALL, WATERBALL, BASIC_PLAYER_BALL}

@export var base_damage: int = 0
@export var flight_speed: float = 10.0

var shot_by_player: bool
var cast_direction: Vector2

func init(_shot_by_player_: bool, _dir: Vector2):
	print("Someone didn't implement the init func D:")

func die():
	projectile_dead.emit(self)

func handle_collision(collision: KinematicCollision2D):
	var collider = collision.get_collider()
	hit.emit(collider)
	if collider is not TileMapLayer:
		if shot_by_player:
			if collider is Enemy:
				collider.health_module.take_damage(base_damage)
		else:
			if collider is Player:
				collider.health_module.take_damage(base_damage)
	

func _physics_process(delta):
	var collision := move_and_collide(cast_direction * flight_speed * delta)
	if collision:
		handle_collision(collision)
