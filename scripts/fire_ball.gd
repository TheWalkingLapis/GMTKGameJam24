extends Spell
class_name FireBall


func init(shot_by_player_: bool, dir: Vector2):
	shot_by_player = shot_by_player_
	cast_direction = dir.normalized()
	look_at(dir.normalized())
	$AnimatedSprite2D.play("cast", flight_speed / 50.0)
	set_collision_layer_value(4, not shot_by_player)
	set_collision_layer_value(5, shot_by_player)
	set_collision_mask_value(2, not shot_by_player)
	set_collision_mask_value(3, shot_by_player)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func handle_collision(collision: KinematicCollision2D):
	super(collision)
	$CollisionShape2D.disabled = true
	if $AnimatedSprite2D.get_frame() <= 5:
		var progress = 1.0 - ((0.5+0.5+0.5) / (0.5+0.5+0.5+1+1+5+0.5+0.5+0.5))
		$AnimatedSprite2D.set_frame_and_progress(6, progress)

func _on_animated_sprite_2d_animation_finished():
	die()
