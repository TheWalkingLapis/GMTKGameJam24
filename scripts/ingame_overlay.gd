extends CanvasLayer

@export var spell_textures: Array[Texture]
@export var attack_bar_textures: Array[Texture]
@export var minimap_room_textures: Array[Texture]

@onready var current_spell_node: TextureRect = $Current_Spell_Border/Current_Spell
@onready var fire_notch_1_fire: TextureRect = $Notches/VBoxContainer/Fire_Notches/TextureRect/TextureRect
@onready var fire_notch_2_fire: TextureRect = $Notches/VBoxContainer/Fire_Notches/TextureRect2/TextureRect
@onready var fire_notch_3_fire: TextureRect = $Notches/VBoxContainer/Fire_Notches/TextureRect3/TextureRect
@onready var water_notch_1_water: TextureRect = $Notches/VBoxContainer/Water_notches/TextureRect/TextureRect
@onready var water_notch_2_water: TextureRect = $Notches/VBoxContainer/Water_notches/TextureRect2/TextureRect
@onready var water_notch_3_water: TextureRect = $Notches/VBoxContainer/Water_notches/TextureRect3/TextureRect
@onready var attack_cd_bar: TextureProgressBar = $Attack_Cooldown_Bar
@onready var health_bar: TextureProgressBar = $Health_Bar
@onready var enemy_kill_bar: TextureProgressBar = $Enemies_Kill_Progress_Bar
@onready var minimap_tl: TextureRect = $MiniMap/GridContainer/TL
@onready var minimap_tc: TextureRect = $MiniMap/GridContainer/TC
@onready var minimap_tr: TextureRect = $MiniMap/GridContainer/TR
@onready var minimap_cl: TextureRect = $MiniMap/GridContainer/CL
@onready var minimap_cc: TextureRect = $MiniMap/GridContainer/CC
@onready var minimap_cr: TextureRect = $MiniMap/GridContainer/CR
@onready var minimap_bl: TextureRect = $MiniMap/GridContainer/BL
@onready var minimap_bc: TextureRect = $MiniMap/GridContainer/BC
@onready var minimap_br: TextureRect = $MiniMap/GridContainer/BR

func set_current_spell_tex(spell: Spell.SpellName):
	if spell == Spell.SpellName.FIREBALL:
		current_spell_node.texture = spell_textures[0]
		attack_cd_bar.texture_progress = attack_bar_textures[0]
	if spell == Spell.SpellName.WATERBALL:
		current_spell_node.texture = spell_textures[1]
		attack_cd_bar.texture_progress = attack_bar_textures[1]
	if spell == Spell.SpellName.BASIC_PLAYER_BALL:
		current_spell_node.texture = spell_textures[2]
		attack_cd_bar.texture_progress = attack_bar_textures[2]

func set_fire_charges(num_charges: int):
	if num_charges < 0 or num_charges > 3:
		return
	fire_notch_1_fire.visible = num_charges >= 1
	fire_notch_2_fire.visible = num_charges >= 2
	fire_notch_3_fire.visible = num_charges >= 3
	
func set_water_charges(num_charges: int):
	if num_charges < 0 or num_charges > 3:
		return
	water_notch_1_water.visible = num_charges >= 1
	water_notch_2_water.visible = num_charges >= 2
	water_notch_3_water.visible = num_charges >= 3

func set_minimap_rooms(rooms: Array[int]):
	minimap_tl.texture = minimap_room_textures[rooms[0]]
	minimap_tc.texture = minimap_room_textures[rooms[1]]
	minimap_tr.texture = minimap_room_textures[rooms[2]]
	minimap_cl.texture = minimap_room_textures[rooms[3]]
	minimap_cc.texture = minimap_room_textures[rooms[4]]
	minimap_cr.texture = minimap_room_textures[rooms[5]]
	minimap_bl.texture = minimap_room_textures[rooms[6]]
	minimap_bc.texture = minimap_room_textures[rooms[7]]
	minimap_br.texture = minimap_room_textures[rooms[8]]

func set_minimap_visibility(set_visible: bool):
	$MiniMap.visible = set_visible

func set_attack_cooldown_bar(percentage: float):
	attack_cd_bar.value = percentage * 100

func set_health_bar(percentage: float):
	health_bar.value = percentage * 100
	
func set_enemy_kill_progress_bar(percentage: float):
	enemy_kill_bar.value = percentage * 100
