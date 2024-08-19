extends CharacterBody2D
class_name Player

signal changed_spell_type(new_type: Spell.SpellName)
signal fireball_charges(charges_left: int)
signal waterball_charges(charges_left: int)
signal attack_cooldown_percentage(percentage: float)

@export var speed = 300.0
@onready var health_module = $HealthState

var selected_spell: Spell.SpellName = Spell.SpellName.FIREBALL
var fire_ball_charges: int = 3 :
	set(value):
		fire_ball_charges = value
		fireball_charges.emit(value)
var water_ball_charges: int = 3 :
	set(value):
		water_ball_charges = value
		waterball_charges.emit(value)

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

	if Input.is_action_just_pressed("next_spell_type"):
		select_next_spell()

	var cd = $CombatModule.get_cooldown_percentage()
	attack_cooldown_percentage.emit(cd)
	if cd >= 1.0:
		if Input.is_action_just_pressed("attack_up"):
			if selected_spell == Spell.SpellName.WATERBALL:
				water_ball_charges -= 1
			elif selected_spell == Spell.SpellName.FIREBALL:
				fire_ball_charges -= 1
			$CombatModule.cast_spell(selected_spell, position + Vector2(0,-1), Vector2(0,-1))
		if Input.is_action_just_pressed("attack_right"):
			if selected_spell == Spell.SpellName.WATERBALL:
				water_ball_charges -= 1
			elif selected_spell == Spell.SpellName.FIREBALL:
				fire_ball_charges -= 1
			$CombatModule.cast_spell(selected_spell, position + Vector2(1,0), Vector2(1,0))
		if Input.is_action_just_pressed("attack_down"):
			if selected_spell == Spell.SpellName.WATERBALL:
				water_ball_charges -= 1
			elif selected_spell == Spell.SpellName.FIREBALL:
				fire_ball_charges -= 1
			$CombatModule.cast_spell(selected_spell, position + Vector2(0,1), Vector2(0,1))
		if Input.is_action_just_pressed("attack_left"):
			if selected_spell == Spell.SpellName.WATERBALL:
				water_ball_charges -= 1
			elif selected_spell == Spell.SpellName.FIREBALL:
				fire_ball_charges -= 1
			$CombatModule.cast_spell(selected_spell, position + Vector2(-1,0), Vector2(-1,0))
	
	if selected_spell == Spell.SpellName.WATERBALL and water_ball_charges <= 0: select_next_spell()
	if selected_spell == Spell.SpellName.FIREBALL and fire_ball_charges <= 0: select_next_spell()
	
	
	

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

func select_next_spell():
	match selected_spell:
			# TODO aa
			Spell.SpellName.FIREBALL:
				if water_ball_charges > 0:
					selected_spell = Spell.SpellName.WATERBALL
					changed_spell_type.emit(selected_spell)
				else:
					# TODO aa
					selected_spell = Spell.SpellName.WATERBALL
			Spell.SpellName.WATERBALL:
				if fire_ball_charges > 0:
					selected_spell = Spell.SpellName.FIREBALL
					changed_spell_type.emit(selected_spell)
				else:
					# TODO aa
					selected_spell = Spell.SpellName.FIREBALL
