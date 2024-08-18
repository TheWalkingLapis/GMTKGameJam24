extends Enemy
class_name Slime

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthState.lethal_damage_taken.connect(die)

func init(player_: Player):
	player = player_

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not player:
		return
	var dir = (player.position - position).normalized()
	velocity = dir * delta * movement_speed
	move_and_slide()
