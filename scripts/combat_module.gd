extends Node
class_name CombatModule

signal enemy_hit(enemy: Object)

var spell_name_to_idx = {Spell.SpellName.FIREBALL: 0, Spell.SpellName.WATERBALL: 1, Spell.SpellName.BASIC_PLAYER_BALL: 2}
@export var is_player: bool = false
@export var spells: Array[PackedScene]
@export var attack_cooldown: float = 0.5
var attack_cooldown_timer: float = 0.5

@onready var spell_instance_node := $SpellInstances

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	attack_cooldown_timer = attack_cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	attack_cooldown_timer += delta

func cast_spell(spell_name: Spell.SpellName, start_pos: Vector2, dir: Vector2):
	if attack_cooldown_timer < attack_cooldown:
		return
	var spell_idx = spell_name_to_idx[spell_name]
	if spell_idx < 0 or spell_idx >= spells.size():
		return
	attack_cooldown_timer = 0.0
	var spell: Spell = spells[spell_idx].instantiate()
	spell.init(is_player, dir)
	spell.position = start_pos
	spell.hit.connect(_on_spell_hit)
	spell.projectile_dead.connect(_on_spell_died)
	spell_instance_node.add_child(spell)

func get_cooldown_percentage():
	return clamp(attack_cooldown_timer / attack_cooldown, 0.0, 1.0)

func _on_spell_hit(obj):
	enemy_hit.emit(obj)

func _on_spell_died(spell):
	spell.queue_free()
