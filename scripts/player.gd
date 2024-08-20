extends CharacterBody2D
class_name Player

signal changed_spell_type(new_type: Spell.SpellName)
signal fireball_charges(charges_left: int)
signal waterball_charges(charges_left: int)
signal attack_cooldown_percentage(percentage: float)

@export var speed = 300.0
@onready var health_module = $HealthState
@export var damage_sounds: Array[AudioStream]

var scaling: float = 1.0 :
	set(value):
		scaling = value
		scale = Vector2(value, value)

func set_scaling(fac: float):
	var step: int = (4 * fac) as int
	scaling = 1.0 + 0.25 * step

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
	$HealthState.damage.connect(play_damage_sound)

func play_damage_sound():
	if $PlayerDamage1.playing:
		if $PlayerDamage2.playing:
			if not $PlayerDamage3.playing:
				$PlayerDamage3.stream = damage_sounds[randi() % damage_sounds.size()]
				$PlayerDamage3.play()
		else:
			$PlayerDamage2.stream = damage_sounds[randi() % damage_sounds.size()]
			$PlayerDamage2.play()
	else:
		$PlayerDamage1.stream = damage_sounds[randi() % damage_sounds.size()]
		$PlayerDamage1.play()

func reset():
	set_scaling(1.0)
	fire_ball_charges = 3
	water_ball_charges = 3
	while(selected_spell != Spell.SpellName.FIREBALL): select_next_spell()
	health_module.dead = false
	health_module.heal(health_module.get_max_hp())

func _process(_delta):
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
		if Input.is_action_pressed("attack_up"):
			if selected_spell == Spell.SpellName.WATERBALL:
				water_ball_charges -= 1
			elif selected_spell == Spell.SpellName.FIREBALL:
				fire_ball_charges -= 1
			play_casting_sound()
			$CombatModule.cast_spell(selected_spell, position + Vector2(0,-1), Vector2(0,-1))
		if Input.is_action_pressed("attack_right"):
			if selected_spell == Spell.SpellName.WATERBALL:
				water_ball_charges -= 1
			elif selected_spell == Spell.SpellName.FIREBALL:
				fire_ball_charges -= 1
			play_casting_sound()
			$CombatModule.cast_spell(selected_spell, position + Vector2(1,0), Vector2(1,0))
		if Input.is_action_pressed("attack_down"):
			if selected_spell == Spell.SpellName.WATERBALL:
				water_ball_charges -= 1
			elif selected_spell == Spell.SpellName.FIREBALL:
				fire_ball_charges -= 1
			play_casting_sound()
			$CombatModule.cast_spell(selected_spell, position + Vector2(0,1), Vector2(0,1))
		if Input.is_action_pressed("attack_left"):
			if selected_spell == Spell.SpellName.WATERBALL:
				water_ball_charges -= 1
			elif selected_spell == Spell.SpellName.FIREBALL:
				fire_ball_charges -= 1
			play_casting_sound()
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
	else:
		$AnimatedSprite2D.animation = "idle"
	
	#position += velocity * delta
	move_and_slide()

func play_casting_sound():
	match selected_spell:
		Spell.SpellName.FIREBALL:
			$FireBall_Attack.play()
		Spell.SpellName.WATERBALL:
			$WaterBall_Attack.play()
		Spell.SpellName.BASIC_PLAYER_BALL:
			$Basic_Attack.play()

func add_fire_charge():
	if fire_ball_charges < 3:
		fire_ball_charges += 1
		if $FireCharge_Gain.playing:
			if not $FireCharge_Gain2.playing:
				$FireCharge_Gain2.play()
		else:
			$FireCharge_Gain.play()
func add_water_charge():
	if water_ball_charges < 3:
		water_ball_charges += 1
		if $WaterCharge_Gain.playing:
			if not $WaterCharge_Gain2.playing:
				$WaterCharge_Gain2.play()
		else:
			$WaterCharge_Gain.play()
func needs_water_charges() -> bool:
	return water_ball_charges < 3
func needs_fire_charges() -> bool:
	return fire_ball_charges < 3

func select_next_spell():
	match selected_spell:
			Spell.SpellName.BASIC_PLAYER_BALL:
				if fire_ball_charges > 0:
					selected_spell = Spell.SpellName.FIREBALL
					changed_spell_type.emit(selected_spell)
				elif water_ball_charges > 0:
					selected_spell = Spell.SpellName.WATERBALL
					changed_spell_type.emit(selected_spell)
			Spell.SpellName.FIREBALL:
				if water_ball_charges > 0:
					selected_spell = Spell.SpellName.WATERBALL
					changed_spell_type.emit(selected_spell)
				else:
					selected_spell = Spell.SpellName.BASIC_PLAYER_BALL
					changed_spell_type.emit(selected_spell)
			Spell.SpellName.WATERBALL:
				selected_spell = Spell.SpellName.BASIC_PLAYER_BALL
				changed_spell_type.emit(selected_spell)
