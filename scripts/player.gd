extends CharacterBody2D
class_name Player

@export var speed = 300.0
@onready var health_module = $HealthState

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

	if Input.is_action_just_pressed("attack_up"):
		$CombatModule.cast_spell(Spell.SpellName.FIREBALL, position + Vector2(0,-1), Vector2(0,-1))
	if Input.is_action_just_pressed("attack_right"):
		$CombatModule.cast_spell(Spell.SpellName.FIREBALL, position + Vector2(1,0), Vector2(1,0))
	if Input.is_action_just_pressed("attack_down"):
		$CombatModule.cast_spell(Spell.SpellName.FIREBALL, position + Vector2(0,1), Vector2(0,1))
	if Input.is_action_just_pressed("attack_left"):
		$CombatModule.cast_spell(Spell.SpellName.FIREBALL, position + Vector2(-1,0), Vector2(-1,0))

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.animation = "walk"
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = true
		elif velocity.x < 0:
			$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	#position += velocity * delta
	move_and_slide()
