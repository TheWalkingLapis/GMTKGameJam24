extends CharacterBody2D
class_name Player

@export var speed = 300.0
#const JUMP_VELOCITY = -400.0


func _ready():
	# callen when node enters the scene-tree
	pass
	
func _process(delta):
	velocity = Vector2.ZERO;
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1

	if Input.is_action_just_pressed("cast_spell"):
		$CombatModule.cast_spell(Spell.SpellName.FIREBALL, position, velocity if velocity.normalized() != Vector2.ZERO else Vector2(1,0))
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = (velocity.x >= 0) # flip horizontally
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	#position += velocity * delta
	move_and_slide()
