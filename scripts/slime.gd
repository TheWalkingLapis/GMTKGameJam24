extends Enemy
class_name Slime

var player: Player
@onready var health_module = $HealthState

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthState.lethal_damage_taken.connect(die)

func init(player_: Player, start_pos: Vector2):
	position = start_pos
	player = player_

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not player:
		return
	var dir = (player.position - position).normalized()
	velocity = dir * delta * movement_speed
	move_and_slide()
