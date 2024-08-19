extends Node2D

@onready var game_controller = $GameController
@onready var ingame_overlay = $IngameOverlay

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var init = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if init:
		game_controller.player.changed_spell_type.connect(ingame_overlay.set_current_spell_tex)
		game_controller.player.fireball_charges.connect(ingame_overlay.set_fire_charges)
		game_controller.player.waterball_charges.connect(ingame_overlay.set_water_charges)
		game_controller.player.attack_cooldown_percentage.connect(ingame_overlay.set_attack_cooldown_bar)
		game_controller.player.health_module.hp_change.connect(ingame_overlay.set_health_bar)
		game_controller.dungeon.enemy_dead.connect(ingame_overlay.set_enemy_kill_progress_bar)
		game_controller.player.health_module.take_damage(0)
		init = false
