extends Enemy
class_name Enemy_Slime_Big

var player: Player
@onready var health_module = $HealthState

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthState.lethal_damage_taken.connect(die)
	$AnimatedSprite2D.play("default")

func init(player_: Player, start_pos: Vector2):
	position = start_pos
	player = player_

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	melee_damage_cd_tracker += delta
	if not player:
		return
	var vec = player.global_position - global_position
	if vec.length() > 16 * 10:
		# dont move
		return
	var dir = vec.normalized()
	velocity = dir * delta * movement_speed
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false # flip horizontally
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	move_and_slide()
	var collision = get_last_slide_collision()
	if collision:
		var collider := collision.get_collider() 
		if collider is Player and melee_damage_cd_tracker > melee_damage_cooldown:
			melee_damage_cd_tracker = 0.0
			player.health_module.take_damage(melee_damage)
			print("HIT")
