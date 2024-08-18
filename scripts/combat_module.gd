extends Node
class_name CombatModule

signal enemy_hit(enemy: Object)

var spell_name_to_idx = {Spell.SpellName.FIREBALL: 0}
@export var spells: Array[PackedScene]

@onready var spell_instance_node := $SpellInstances

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func cast_spell(spell_name: Spell.SpellName, start_pos: Vector2, dir: Vector2):
	var spell_idx = spell_name_to_idx[spell_name]
	if spell_idx < 0 or spell_idx >= spells.size():
		return
	var spell: Spell = spells[spell_idx].instantiate()
	spell.init(dir)
	spell.position = start_pos
	spell.enemy_hit.connect(_on_spell_enemy_hit)
	spell.projectile_dead.connect(_on_spell_died)
	spell_instance_node.add_child(spell)

func _on_spell_enemy_hit(obj):
	enemy_hit.emit(obj)

func _on_spell_died(spell):
	spell.queue_free()
